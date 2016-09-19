package ModernTimes::Evento::Builder;
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

  sub rndStr{ join'', @_[ map{ rand @_ } 1 .. shift ] }

  sub build {
    my $self = shift;
    my $args = shift;
    $self->evento(ModernTimes::Evento->new) if !$self->evento;
    my $tipo = $args->{tipo};
    my $tipo = Universo->actual->evento_tipo($tipo);
    $self->evento->name(rndStr 32, 'a'..'z','A'..'Z', 0..9);
    $self->evento->tipo($tipo);
    $self->evento->epoch($args->{epoch}) if $args->{epoch};
    $self->evento->epoch(Universo->actual->base_date->epoch) if !$args->{epoch};
    foreach my $rol (@{$tipo->roles}) {
      my $personaje = $args->{$rol};
      $personaje = Entorno->traer_o_crear($args->{$rol});
      $self->evento->$rol($personaje);
      push @{$personaje->eventos}, $self->evento;
      Entorno->actual->agregar($self->evento);
    }
    return $self;  	
  }


1;