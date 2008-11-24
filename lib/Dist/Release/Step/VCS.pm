package Dist::Release::Step::VCS;

use Moose;

extends 'Dist::Release::Step';
our $VERSION = '0.0_3';

sub check {
    my $self = shift;

    my $vcs_name = $self->distrel->vcs_name
      or return $self->error('no vcs has been detected');

    my $subclass = ref($self) . "::$vcs_name";

    eval qq{ require $subclass };

    if ($@) {
        return $self->error("couldn't load sub-step for VCS $vcs_name:\n$@");
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->check;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

1;

