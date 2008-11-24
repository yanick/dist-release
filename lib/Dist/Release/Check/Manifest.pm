package Dist::Release::Check::Manifest;

use Moose;

extends 'Dist::Release::Step::Builder';
our $VERSION = '0.0_3';

1;

__END__

=head1 NAME

Dist::Release::Check::Manifest - verifies that the manifest is up-to-date

=head1 DESCRIPTION

This is the generic L<Dist::Release> step that
verifies that the distribution's F<MANIFEST>
is in line with the content of the working directory.  The
actual check is done by the relevant builder-dependent sub-module. 

=head1 CONFIGURATION

This step only requires to be added to the list of 
checks in the F<distrelease.yml> config file.  

The detection of the builder used by the distribution is done 
automatically (see L<Dist::Release::Step::Builder> for more
details).


=head1 SEE ALSO

=over

=item L<Dist::Release::Check::Manifest::Build>

=item L<Dist::Release>

=back

=cut
