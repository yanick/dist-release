use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Dist::Release',
    license             => 'perl',
    dist_author         => 'Yanick Champoux <yanick@cpan.org>',
    dist_version_from   => 'lib/Dist/Release.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Dist-Release-*' ],
);

$builder->create_build_script();
