package ModernTimes::Builder::Personaje;
use fields qw(_personajes _argumentos);
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

  sub personaje {
    my $self = shift;
  	my $valor = shift;
  	$self->{_personajes} = $valor if defined $valor;
  	return $self->{_personajes};
  }

  sub argumentos {
    my $self = shift;
  	my $valor = shift;
  	$self->{_argumentos} = $valor if defined $valor;
  	return $self->{_argumentos};
  }

  sub build {
    my $self = shift;
    my $args = shift;
    $self->argumentos($args);
	$self->asignar_atributo('sex');
	return $self;  	
  }

  sub asignar_atributo {
    my $self = shift;
	my $key = shift;
	return if $self->personaje->$key;
	my $validos = Universo->actual->atributo_tipo($key)->validos;
	my $valor = $self->argumentos->{$key} if exists $self->argumentos->{$key};
	$valor = $validos->[int rand scalar @{$validos}] if !$valor;
	$self->personaje->$key($valor); 	
  }
1;