package Dist::Release::Check::VCS::WorkingDirClean::Git;

use Moose;

extends 'Dist::Release::Step';

our $VERSION = '0.0_5';

sub check {
    my $self = shift;

    return $self->error('no Git repository detected')
      unless 'Git' eq ref $self->distrel->vcs;

    my $result = `git status`;

    $self->error( 'working directory is not clean' . "\n" . $result )
      unless $result =~ /working directory clean/;
}

1;
