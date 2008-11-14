package Dist::Release::Step::Builder;

use Moose;

extends 'Dist::Release::Step';

our $VERSION = '0.0_1';

sub check {
    my $self = shift;

    my $builder = $self->distrel->builder
      or return $self->error('no builder has been detected');

    my $subclass = ref($self) . "::$builder";

    eval qq{ require $subclass };

    if ($@) {
        return $self->error(
            "couldn't load sub-step for builder $builder:\n$@");
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->check;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

sub release {
    my $self = shift;

    my $builder = $self->distrel->builder
      or return $self->error('no builder has been detected');

    my $subclass = ref($self) . "::$builder";

    eval qq{ require $subclass };

    if ($@) {
        return $self->error(
            "couldn't load sub-step for builder $builder:\n$@");
    }

    my $subtest = $subclass->new( distrel => $self->distrel );

    $subtest->release;

    $self->set_log( $subtest->log );
    $self->set_failed( $subtest->failed );
}

1;

__END__

=head1 NAME

Dist::Release::Step::Builder - builder-specific step parent class

=head1 DESCRIPTION

This class is meant to be used as the base class of 
builder-dependent steps, so that when the step is called,
its actions are automagically dispatched to the sub-step associated
with the builder used by the distribution.

More clearly, assuming the generic step is called I<DoStuff>, if 
'Module::Build' is used then the step module I<DoStuff::Build> is
going to be used.  If it's 'MakeMaker', then it's going to be
the module I<DoStuff::MakeMaker>.

=head1 SUPPORTED BUILDERS

See the builders recognized by L<Dist::Release/builder>. 

=head1 version

This documentation refers to Dist::Release version 0.0_1.

=head1 AUTHOR 

Yanick Champoux, <yanick@cpan.org>.

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 Yanick Champoux (<yanick@cpan.org>). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

