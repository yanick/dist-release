package Dist::Release::Action::GenerateDistribution::Build;

use '5.10.0';

use Moose;

use IPC::Cmd 'run';

extends 'Dist::Release::Action';

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub release {
    my $self = shift;

    say "running 'Build dist'";

    unless ( $self->distrel->pretend ) {
        unless ( scalar run( command => [qw# ./Build dist #] ) ) {
            $self->error('Build dist failed');
        }
    }

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1;

