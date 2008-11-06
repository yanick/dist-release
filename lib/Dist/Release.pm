package Dist::Release;

use strict;
use warnings;

use Moose::Policy 'MooseX::Policy::SemiAffordanceAccessor';
use Moose;


use YAML;
use Term::ANSIColor;

use Readonly;

Readonly my $rc_filename => 'distrelease.yml';

has 'config', 
    is => 'ro',
    builder => 'load_config';

has 'actions',
    isa => 'ArrayRef[Str]'
    ;

has 'checks',
    isa => 'ArrayRef[Str]';

has 'vcs',
    builder => 'detect_vcs',
    is => 'rw';

sub actions {
    return @{ $_[0]->{actions}||=[] };
}

sub checks {
    return @{ $_[0]->{checks}||=[] };
}
sub add_actions {
    my( $self, @actions ) = @_;

    push @{$self->{actions}}, @actions;
}

sub add_checks {
    my( $self, @checks ) = @_;

    push @{$self->{checks}}, @checks;
}

sub clear_actions {
    $_[0]->{actions} = [];
}

sub clear_checks {
    $_[0]->{checks} = [];
}

sub load_config {
    my $self = shift;

    die "no file '$rc_filename' found\n" unless -f $rc_filename;

    my $config = YAML::LoadFile( $rc_filename );

    if ( $config->{actions} ) {
        $self->add_actions( @{$config->{actions} } );    
    }

    if ( $config->{checks} ) {
        $self->add_checks( @{$config->{checks} } );    
    }

    for my $step ( $self->checks ) {
        eval "require Dist::Release::Check::$step; 1;" 
            or die "couldn't load release step '$step'\n$@";
    }

    for my $step ( $self->actions ) {
        eval "require Dist::Release::Action::$step; 1;" 
            or die "couldn't load release step '$step'\n$@";
    }

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
        # exit 1;
    }
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

            print $s->log;

            return $pass;
}

sub release {
    my $self = shift;

    $self->check;

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


1;
