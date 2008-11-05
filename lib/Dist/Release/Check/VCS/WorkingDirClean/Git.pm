package Dist::Release::Check::VCS::WorkingDirClean::Git;

use Moose;

with 'Dist::Release::Step';

sub check {
    my $self = shift;
    my $drel  = shift;

    return $self->error( 'no Git repository detected' ) 
        unless 'Git' eq ref $drel->vcs; 

    my $git = $drel->vcs;

    $DB::single = 1;
    my $result = $git->command( 'status' );

    $self->error( 'working directory is not clean' ) 
        unless $result =~ /working dir is clean/;
}



