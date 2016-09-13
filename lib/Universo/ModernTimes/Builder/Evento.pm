package ModernTimes::Builder::Evento;
use fields qw(_evento _argumentos);
use strict;
use Data::Dumper;
use JSON;
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_argumentos} = {};
    Gaiman->logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub evento {
    my $self = shift;
  	my $valor = shift;
  	$self->{_evento} = $valor if defined $valor;
  	return $self->{_evento};
  }

  sub build {
    my $self = shift;
    my $args = shift;
    return $self;  	
  }


1;