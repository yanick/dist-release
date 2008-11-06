package Dist::Release::Action;

use Moose;

extends 'Dist::Release::Step';

sub check {
    # its okay for an action not to have a check phase
    $_[0]->diag( 'no check implemented' );
}

sub release {
    $_[0]->error('release not implemented!');
}

before release => sub {
    my $self = shift;
    $self->set_failed(0);
};

1;
