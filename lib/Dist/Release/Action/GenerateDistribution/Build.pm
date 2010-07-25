package Dist::Release::Action::GenerateDistribution::Build;

use 5.10.0;

use Moose;
our $VERSION = '0.0_5';

use IPC::Cmd 'run';

extends 'Dist::Release::Action';

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub release {
    my $self = shift;

    $self->diag("running 'Build dist'");

    unless ( $self->distrel->pretend ) {
        unless ( scalar run( command => [qw# ./Build dist #] ) ) {
            $self->error('Build dist failed');
        }
    }

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1;

