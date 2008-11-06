package Dist::Release::Action;

use Moose;

extends 'Dist::Release::Step';

sub check {
    $_[0]->diag( 'no check implemented' );
}

sub release {
    $_[0]->error('release not implemented!');
}

1;
