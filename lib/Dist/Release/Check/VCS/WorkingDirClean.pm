package Dist::Release::Check::VCS::WorkingDirClean;

use Moose;

extends 'Dist::Release::Step';

sub check {
    my $self = shift;

    my $vcs_name = $self->distrel->vcs_name
        or return $self->error( 'no vcs has been detected' );

    my $subclass = __PACKAGE__ . "::$vcs_name";

    eval qq{ require $subclass };
    
    if( $@ ) {
        return $self->error( "couldn't load sub-step for VCS $vcs_name:\n$@" );
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->check;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

1;
