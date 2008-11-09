package Dist::Release::Step::Builder;

use Moose;

extends 'Dist::Release::Step';

sub check {
    my $self = shift;

    my $builder = $self->distrel->builder
      or return $self->error('no builder has been detected');

    my $subclass = ref($self) . "::$builder";

    eval qq{ require $subclass };

    if ($@) {
        return $self->error(
            "couldn't load sub-step for builder $builder:\n$@");
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->check;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

sub release {
    my $self = shift;

    my $builder = $self->distrel->builder
      or return $self->error('no builder has been detected');

    my $subclass = ref($self) . "::$builder";

    eval qq{ require $subclass };

    if ($@) {
        return $self->error(
            "couldn't load sub-step for builder $builder:\n$@");
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->release;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

1;

