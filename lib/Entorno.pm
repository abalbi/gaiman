package Entorno;
use fields qw(_personajes _eventos);
use strict;
use Data::Dumper;
use JSON;
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_personajes} = [];
    $self->{_eventos} = [];
    Gaiman->logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub actual {
    my $self = shift;
    $actual = Entorno->new if !$actual;
    return $actual;
  }

  sub agregar {
    my $self = shift;
    $self = Entorno->actual if $self eq 'Entorno';
  	my $obj = shift;
    if ($obj->isa('Personaje')) {
      return 0 if $self->buscar($obj->name);
      return push @{$self->personajes}, $obj if $obj->isa('Personaje');
    } 
    if ($obj->isa('Evento')) {
      return 0 if $self->buscar($obj->name);
      return push @{$self->eventos}, $obj if $obj->isa('Evento');
    } 
  }

  sub buscar {
    my $self = shift;
    my $key = shift;
    $self = Entorno->actual if $self eq 'Entorno';
    my $objs = [grep {$_->es($key)} @{$self->personajes}];
    return $objs->[0] if scalar @{$objs} == 1;
    return undef if scalar @{$objs} == 0;
    return $objs;
  }

  sub traer_o_crear {
    my $self = shift;
    my $args = shift;
    my $personaje;
    my $builder_personaje = Universo->actual->builder_personaje->clean;
    if(ref $args) {
      if (ref $args eq 'HASH') {
        $builder_personaje->build($args);
        $personaje = $builder_personaje->personaje;
      } elsif($args->isa('Personaje')) {
        $personaje = $args;
      }
    } else {
      $builder_personaje->build;
      $personaje = $builder_personaje->personaje;
    }
    return $personaje;
  }

  sub personajes {
    my $self = shift;
    return $self->{_personajes};
  }

  sub eventos {
    my $self = shift;
    return $self->{_eventos};
  }

1;