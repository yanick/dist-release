package Dist::Release;

use 5.10.0;

use strict;
use warnings;

use Moose::Policy 'MooseX::Policy::SemiAffordanceAccessor';
use Moose;

use YAML;
use Term::ANSIColor;
use Hash::Merge 'merge';
use Readonly;

our $VERSION = '0.0_2';

Readonly my $rc_filename => 'distrelease.yml';

has 'config',
  is      => 'ro',
  builder => 'load_config';

has 'actions',
  isa         => 'ArrayRef',
  initializer => 'init_actions',
  ;

has 'checks',
  isa         => 'ArrayRef',
  initializer => 'init_checks',
  ;

has 'vcs',
  builder => 'detect_vcs',
  is      => 'rw';

has builder => ( builder => 'detect_builder', is => 'ro' );

has check_only => ( is => 'rw' );

has pretend => ( is => 'ro', default => 1 );

has stash => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

sub detect_builder {
    return
        -f 'Build.PL'    ? 'Build'
      : -f 'Makefile.PL' ? 'MakeMaker'
      : -f 'inc'         ? 'ModuleInstall'
      :                    undef;
}

sub run {
    my $self = shift;

    if ( $self->pretend ) {
        say 'Dist::Release will only pretend to perform the actions ',
          '(use --doit for the real deal)';
    }

    my $fails = $self->check;

    exit if $self->check_only;

    if ($fails) {
        say 'some checks failed, aborting the release';
        exit 1;
    }

    $self->release;
}

sub init_actions {
    my ( $self, $value, $set ) = @_;

    if ( 'ARRAY' eq ref $value ) {
        $self->add_actions(@$value);
    }

}

sub init_checks {
    my ( $self, $value, $set ) = @_;

    if ( 'ARRAY' eq ref $value ) {
        $self->add_checks(@$value);
    }
}

sub actions {
    return @{ $_[0]->{actions} ||= [] };
}

sub checks {
    return @{ $_[0]->{checks} ||= [] };
}

sub add_actions {
    my ( $self, @actions ) = @_;

    for my $step (@actions) {
        eval "require Dist::Release::Action::$step; 1;"
          or die "couldn't load release step '$step'\n$@";
    }

    push @{ $self->{actions} }, @actions;

    return $self->{actions};
}

sub add_checks {
    my ( $self, @checks ) = @_;

    $self->{checks} ||= [];

    for my $step (@checks) {
        eval "require Dist::Release::Check::$step; 1;"
          or die "couldn't load check step '$step'\n$@";
        push @{ $self->{checks} }, $step;
    }

    return $self->{checks};
}

sub clear_actions {
    $_[0]->{actions} = [];
}

sub clear_checks {
    $_[0]->{checks} = [];
}

sub BUILD {
    my $self = shift;

    $self->add_checks( @{ $self->config->{checks} } )   unless $self->checks;
    $self->add_actions( @{ $self->config->{actions} } ) unless $self->actions;
}

sub load_config {
    my $self = shift;

    my @configs = map { YAML::LoadFile($_) }
      grep { -f $_ }
      map { "$_/$rc_filename" } $ENV{HOME}, '.'
      or die "no file '$rc_filename' found\n";

    my $config = @configs == 1 ? $configs[0] : merge(@configs);

    return $config;
}

sub detect_vcs {
    my $self = shift;

    if ( -d '.git' ) {
        require Git;
        my $repo = Git->repository;
        $self->set_vcs($repo);
    }

}

sub vcs_name {
    my $self = shift;

    my %mod2name = ( Git => 'Git', );

    return $mod2name{ ref $self->vcs };
}

sub check {
    my $self = shift;

    my $failed_checks;

    print "running check cycle...\n";

    print "regular checks\n";

    $failed_checks += !$self->check_single($_) for $self->checks;

    print "pre-action checks\n" if $self->actions;

    $failed_checks += !$self->check_single( $_, 'Action' ) for $self->actions;

    if ($failed_checks) {
        print $failed_checks . ' checks failed' . "\n";
    }

    return $failed_checks;
}

# return true on success, false on failure
sub check_single {
    my $self      = shift;
    my $checkname = shift;
    my $type      = shift || 'Check';

    my $pass = 1;
    printf "%-30s    ", $_;
    my $s = "Dist::Release::${type}::$checkname"->new( distrel => $self );
    $s->check;

    if ( $s->failed ) {
        print '[' . colored( 'failed', 'red' ) . "]\n";
        $pass = 0;
    }
    else {
        print '[' . colored( 'passed', 'green' ) . "]\n";

    }

    no warnings qw/ uninitialized /;
    print $s->log;

    return $pass;
}

sub release {
    my $self = shift;

    print "running release cycle...\n";

    my @actions = $self->actions;
    while ( my $a = shift @actions ) {
        my $name = $a;
        printf "%-30s    ", $a;
        $a = "Dist::Release::Action::$a"->new( distrel => $self );
        $a->release;

        if ( $a->failed ) {
            print '[' . colored( 'failed', 'red' ) . "]\n";
            print $a->log;
            print "release actions not run to completion: ",
              join( ', ', $name, @actions ), "\n";
            exit;
        }
        else {
            print '[' . colored( 'passed', 'green' ) . "]\n";

        }

        print $a->log;
    }

}

sub print_steps {
    my $self = shift;

    say 'checks';
    say "\t$_" for $self->checks;
    say 'actions';
    say "\t$_" for $self->actions;

}

1;

__END__

=head1 NAME

Dist::Release - manages the process of releasing a module 

=head1 DESCRIPTION

Dist::Release is meant to help CPAN authors automate the 
release process of their modules. In Dist::Release, the 
release process is seen as a sequence of steps. There are two 
different kind of steps: checks and actions. Checks are non-intrusive 
verifications (i.e., they're not supposed to touch anything), 
and actions are the steps that do the active part of the release. 
When one launches a release, checks are done first. If some fail, 
we abort the process. If they all pass, then we are good to go and the actions are done as well. 


The rest of this documentation deals with the guts of Dist::Release and
how to write new steps.  If you are rather interested in using Dist::Release,
look at the documentation of L<distrelease>.

=head1 METHODS

=head2 builder

Guesses the name of the build module used by the distribution.
Returns 'Build' for 'Module::Build',
'MakeMaker' for 'ExtUtils::MakeMaker',
'ModuleInstall' for 'Module::Install' and
I<undef> if it couldn't find anything.

=head1 SEE ALSO

L<Module::Release> - another module tackling the same task.


=head1 version

This documentation refers to Dist::Release version 0.0_1.

=head1 AUTHOR 

Yanick Champoux, <yanick@cpan.org>.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 Yanick Champoux (<yanick@cpan.org>). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

