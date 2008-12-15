package Dist::Release::Check::SaneVersion;

use Moose;

extends 'Dist::Release::Step';

use Dist::Release::Version;

our $VERSION = '0.0_3';

sub check {
    my $self = shift;

    my $v = $self->distrel->version;

    $self->diag("distribution version is '$v'");

}

1;

