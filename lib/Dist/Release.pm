package Dist::Release;

use strict;
use warnings;

use Moose;

use YAML;
use Term::ANSIColor;

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

    die "no 'release.yaml' present" unless -f 'release.yaml';

    my $config = YAML::LoadFile( 'release.yaml' );

    if ( $config->{actions} ) {
        $self->add_actions( @{$config->{actions} } );    
    }

    if ( $config->{checks} ) {
        $self->add_checks( @{$config->{checks} } );    
    }

    for my $step ( $self->actions, $self->checks ) {
        eval "require Dist::Release::Check::$step; 1;" 
            or die "couldn't load release step '$step'\n$@";
    }

    return $config;
}

sub detect_vcs {
    my $self = shift;

    if ( -d '.git' ) {
        require Git;
        my $repo = Git->repository;
        $self->vcs( $repo );
    }

}

sub check {
    my $self = shift;

    my $failed_checks;

    print "running check cycle...\n";

    print "regular checks\n";

        for ( $self->checks ) {
            printf "%30s    ", $_;
            my $s = "Dist::Release::Check::$_"->new;
            $s->check( $self );

            if( $s->fails ) {
                print '['. colored(  'failed', 'red' ) . "]\n";
                print $s->_error;
                $failed_checks++;
            }
            else {
                print '['. colored(  'passed', 'green' ) . "]\n";
            }
        }

    print "pre-action checks\n" if $self->actions;

    for ( $self->actions ) {
        printf "%30s    ", $_;
        my $c = $_->new;
        $c->check;

            if( $c->fails ) {
                print '['. colored(  'failed', 'red' ) . "]\n";
                $failed_checks++;
            }
            else {
                print '['. colored(  'passed', 'green' ) . "]\n";
            }

    }

    if ( $failed_checks ) {
        print $failed_checks . ' checks failed'."\n";
        exit 1;
    }
}

sub release {
    my $self = shift;

    $self->check;

    print "running release cycle...\n";

    my @actions = $self->actions;
    while ( my $a = shift @actions ) {
        print "$a\n";
        $a = $_->new;    
        $a->release;

        if ( $a->fails ) {
            print "release failed!\n";
            print "release actions not run: ", join( ', ', @actions ), "\n"
                if @actions;
            exit;
        }
    }

}


1;
