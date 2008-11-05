package Dist::Release;

use strict;
use warnings;

use Moose;

use YAML;

has 'config', 
    is => 'ro',
    builder => 'load_config';

has 'actions',
    isa => 'ArrayRef[Str]'
    ;

has 'checks',
    isa => 'ArrayRef[Str]'
    ;

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
        eval "require $step; 1;" 
            or die "couldn't load release step '$step': $@";
    }

    return $config;
}


sub check {
    my $self = shift;

    print "running check cycle...\n";

    print "pure checks\n";

        for ( $self->checks ) {
            print $_, "\n";
            my $s = $_->new;
            $s->check();

            if( $s->fails ) {
                die "check failed: $@";
            }
            else {
                print "check passed\n";
            }
        }

    print "pre-action checks\n";

    for ( $self->actions ) {
        print "$_\n";
        my $c = $_->new;
        $c->check;

            if( $c->fails ) {
                die "check failed: $@";
            }
            else {
                print "check passed\n";
            }

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
