package M::R::Action;

use Moose::Role;

use strict;
use warnings;

has 'fails' => ( default => 0, is => 'rw' );

requires 'check';

before check => sub {
    my $self = shift;
    $self->fails(0);
};

sub error {
    my( $self, @msg ) = @_;

    if ( @msg ) {
        print map "$_\n" => @msg;
    }

    $self->fails(1);
}

sub diag {
    my $self = shift;

    print map "$_\n" => @_;
}

1;


