package Dist::Release::Check::VCS::BumpedVersion::Git;

use Moose;

extends 'Dist::Release::Step';

use version 'qv';

our $VERSION = '0.0_4';

sub check {
    my $self = shift;

    my $version = $self->distrel->version;

    my $last_tagged_version = $self->last_tagged_version;

    $self->diag("dist version: $version");
    $self->diag("last tagged version: $last_tagged_version");

    $self->error("version hasn't been incremented")
      unless qv($last_tagged_version) < qv($version);
}

sub last_tagged_version {
    my $self = shift;
    my $git  = $self->distrel->vcs;

    no warnings qw/ uninitialized /;

    my ( $git_v, $past );

    # TODO: make this safe from infinite looping
    while ( $git_v !~ /^v\d+/ ) {    # isn't a version
        ( $git_v, $past ) = split '-' => $git->command(
            describe => '--tags',
            ( $git_v . '^' ) x !!$git_v
        );
    }

    return wantarray ? ( $git_v, $past ) : $git_v;

}

1;

