package Dist::Release::Step;

use Moose::Policy 'MooseX::Policy::SemiAffordanceAccessor';
use Moose;
our $VERSION = '0.0_4';

has 'failed' => ( default => 0, is => 'rw' );
has 'log' => ( is => 'rw' );

has distrel => ( is => 'ro', required => 1 );

sub check {
    $_[0]->error('check not implemented!');
}

before check => sub {
    my $self = shift;
    $self->set_failed(0);
};

sub error {
    my ( $self, @msg ) = @_;

    s/\s*$/\n/ for @msg;

    no warnings qw/ uninitialized /;
    $self->set_log( $self->log . join '', @msg );

    $self->set_failed(1);
}

sub diag {
    my $self = shift;

    my @msg = @_;

    s/\s*$/\n/ for @msg;

    no warnings qw/ uninitialized /;
    $self->set_log( $self->log . join '', @msg );
}

1;

