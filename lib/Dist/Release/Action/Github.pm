package Dist::Release::Action::Github;

use Moose;

use CPAN::Uploader;

extends 'Dist::Release::Action';

our $VERSION = '0.0_3';

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub check {
    my ($self) = @_;

    # we have 'github' registered as a remote repo

    $self->error(q{this doesn't look like a Git repository})
      unless $self->distrel->vcs_name eq 'Git';

    my @remotes = $self->distrel->vcs->command('remote');

    $self->error(q{no 'github' remote repository found})
      unless 'github' ~~ @remotes;

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub release {
    my $self = shift;

    unless ( $self->distrel->pretend ) {
        $self->distrel->vcs->command( push => '--tags', 'github', 'master' );
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1;

__END__

=head1 NAME

Dist::Release::Action::Github - pushes repository changes to Github

=head1 DESCRIPTION

Pushes local changes of the master branch and new tags 
to the Github remote repository (which is expected
to be named 'github').

