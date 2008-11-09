package Dist::Release;

use 5.10.0;

use strict;
use warnings;

use Moose::Policy 'MooseX::Policy::SemiAffordanceAccessor';
use Moose;


use YAML;
use Term::ANSIColor;
use Hash::Merge 'merge';

use Readonly;

Readonly my $rc_filename => 'distrelease.yml';

has 'config', 
    is => 'ro',
    builder => 'load_config';

has 'actions',
    isa => 'ArrayRef',
    initializer => 'init_actions',
    ;

has 'checks',
    isa => 'ArrayRef',
    initializer => 'init_checks',
    ;

has 'vcs',
    builder => 'detect_vcs',
    is => 'rw';

has check_only => ( is => 'rw' );

has pretend => ( is => 'ro', default => 1 );

has stash => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

sub run {
    my $self = shift;

    if ( $self->pretend ) {
        say 'Dist::Release will only pretend to perform the actions ',
            '(use --doit for the real deal)';
    }

    my $fails = $self->check;

    exit if $self->check_only;

    if ( $fails ) {
        say 'some checks failed, aborting the release';
        exit 1;
    }

    $self->release;
}

sub init_actions {
    my ( $self, $value, $set  ) = @_;

    if( 'ARRAY' eq ref $value ) {
        $self->add_actions( @$value );
    }

}

sub init_checks {
    my ( $self, $value, $set  ) = @_;

    if( 'ARRAY' eq ref $value ) {
        $self->add_checks( @$value );
    }
}


sub actions {
    return @{ $_[0]->{actions}||=[] };
}

sub checks {
    return @{ $_[0]->{checks}||=[] };
}


sub add_actions {
    my( $self, @actions ) = @_;

    for my $step ( @actions ) {
        eval "require Dist::Release::Action::$step; 1;" 
            or die "couldn't load release step '$step'\n$@";
    }

    push @{$self->{actions}}, @actions;

    return $self->{actions};
}

sub add_checks {
    my( $self, @checks ) = @_;

    $self->{checks}||=[];

    for my $step ( @checks ) {
        eval "require Dist::Release::Check::$step; 1;" 
            or die "couldn't load check step '$step'\n$@";
        push @{$self->{checks}}, $step;
    }

    return $self->{checks};
}

sub clear_actions {
    $_[0]->{actions} = [];
}

sub clear_checks {
    $_[0]->{checks} = [];
}

sub BUILD {
    my $self = shift;

    unless ( $self->checks or $self->actions ) {
        $self->add_checks( @{ $self->config->{checks} } );
        $self->add_actions( @{ $self->config->{actions} } );
    }

}

sub load_config {
    my $self = shift;

    my @configs = map { YAML::LoadFile( $_ ) } 
                  grep { -f $_ } 
                  map { "$_/$rc_filename" } $ENV{HOME}, '.'
        or die "no file '$rc_filename' found\n";

    my $config = @configs == 1 ? $configs[0] : merge( @configs );

    return $config;
}

sub detect_vcs {
    my $self = shift;

    if ( -d '.git' ) {
        require Git;
        my $repo = Git->repository;
        $self->set_vcs( $repo );
    }

}

sub vcs_name {
    my $self = shift;

    my %mod2name = (
        Git => 'Git',
    );

    return $mod2name{ ref $self->vcs };
}

sub check {
    my $self = shift;

    my $failed_checks;

    print "running check cycle...\n";

    print "regular checks\n";

    $failed_checks += ! $self->check_single( $_ ) for $self->checks;

    print "pre-action checks\n" if $self->actions;

    $failed_checks += ! $self->check_single( $_, 'Action' ) for $self->actions;

    if ( $failed_checks ) {
        print $failed_checks . ' checks failed'."\n";
    }

    return $failed_checks;
}

# return true on success, false on failure
sub check_single {
    my $self = shift;
    my $checkname = shift;
    my $type = shift || 'Check';

            my $pass = 1;
            printf "%-30s    ", $_;
            my $s = "Dist::Release::${type}::$checkname"->new( distrel => $self );
            $s->check;

            if( $s->failed ) {
                print '['. colored(  'failed', 'red' ) . "]\n";
                $pass = 0;
            }
            else {
                print '['. colored(  'passed', 'green' ) . "]\n";

            }

            no warnings qw/ uninitialized /;
            print $s->log;

            return $pass;
}

sub release {
    my $self = shift;

    print "running release cycle...\n";

    my @actions = $self->actions;
    while ( my $a = shift @actions ) {
            printf "%-30s    ", $a;
        $a = "Dist::Release::Action::$a"->new( distrel => $self );    
        $a->release;


            if( $a->failed ) {
                print '['. colored(  'failed', 'red' ) . "]\n";
                print "release actions not run: ", join( ', ', @actions ), "\n" if @actions;
                print $a->log;
            exit;
            }
            else {
                print '['. colored(  'passed', 'green' ) . "]\n";

            }

            print $a->log;
    }

}

sub print_steps {
    my $self = shift;

    say 'checks';
    say "\t$_" for $self->checks;
    say 'actions';
    say"\t$_" for $self->actions;


}


1;
