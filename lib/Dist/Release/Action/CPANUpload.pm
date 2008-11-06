package Dist::Release::Action::CPANUpload;

use Moose;

extends 'Dist::Release::Action';

sub release {
    my $self = shift;

    $self->diag( 'uploading some file to CPAN' );
}



1;
