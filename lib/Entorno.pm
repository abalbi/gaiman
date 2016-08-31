package Entorno;
use fields qw(_personajes);
use strict;
use Data::Dumper;
use JSON;
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_personajes} = [];
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
      print STDERR Dumper $self->buscar($obj->name);
  		return push @{$self->personajes}, $obj if $obj->isa('Personaje');
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

  sub personajes {
    my $self = shift;
    return $self->{_personajes};
  }
1;