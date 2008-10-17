package M::R::Action::DoSomething;

use Moose;

with 'M::R::Action';

sub check {
    my $self = shift;
    # all is good
    $self->error( "this is not good" );
}

1;



