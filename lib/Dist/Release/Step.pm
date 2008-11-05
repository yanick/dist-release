package Dist::Release::Step;

use Moose::Role;

use strict;
use warnings;

has 'fails' => ( default => 0, is => 'rw' );
has '_error' => ( is => 'rw' );

requires 'check';

before check => sub {
    my $self = shift;
    $self->fails(0);
};

sub error {
    my( $self, @msg ) = @_;

    no warnings qw/ uninitialized /;
    $self->_error( join "\n", $self->_error, @msg  );

    $self->fails(1);
}

sub diag {
    my $self = shift;

    print map "$_\n" => @_;
}

1;


