package Dist::Release::Check::SaneVersion;

use Moose;

extends 'Dist::Release::Step';

use Dist::Release::Version;

our $VERSION = '0.0_3';

sub check {
    my $self = shift;

    my $v = Dist::Release::Version->new;

    my $version = eval { $v->version; };

    if ($@) {
        return $self->error($@);
    }

    $self->diag("distribution version is '$version'");

}

1;

