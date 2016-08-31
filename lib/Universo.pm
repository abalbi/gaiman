package Universo;
use fields qw();

our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    Gaiman->logger->info("Se instancio ",ref $self);
    $actual = $self;
    return $self;
  }

  sub actual {
  	my $class = shift;
  	return $actual;
  }
1;