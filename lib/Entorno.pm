package Entorno;
use fields qw(_elementos);
use strict;
use Data::Dumper;
use JSON;
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_elementos} = [];
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
    return 0 if $self->buscar($obj->name);
    return push @{$self->elementos}, $obj;
  }

  sub buscar {
    my $self = shift;
    my $key = shift;
    $self = Entorno->actual if $self eq 'Entorno';
    my $objs = [grep {$_->es($key)} @{$self->elementos}];
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
    my $array = [grep {$_->isa('Personaje')} @{$self->elementos}];
    return $array;
  }

  sub eventos {
    my $self = shift;
    my $array = [grep {$_->isa('Evento')} @{$self->elementos}];
    return $array;
  }

  sub elementos {
    my $self = shift;
    return $self->{_elementos};
  }


1;