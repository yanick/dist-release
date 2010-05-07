package Dist::Release::Check::Manifest::Build;

use Moose;

use IPC::Cmd 'run';

extends 'Dist::Release::Step';
our $VERSION = '0.0_4';

sub check {
    my $self = shift;

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      run( command => [qw# ./Build distcheck #] );

    return $self->error( join '', @$full_buf )
      if not $success
          or grep /not in sync/ => @$stderr_buf;

}

1;
