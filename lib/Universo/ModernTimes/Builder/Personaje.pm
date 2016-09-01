package ModernTimes::Builder::Personaje;
use fields qw(_personaje _argumentos _estructura);
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
  	$self->{_personaje} = $valor if defined $valor;
  	return $self->{_personaje};
  }

  sub estructura {
    my $self = shift;
    my $valor = shift;
    $self->{_estructura} = $valor if defined $valor;
    return $self->{_estructura};
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
    $self->estructura({});
    $self->preparar('sex');
    $self->preparar('name');
    $self->preparar('virtues', 10);
    $self->asignar;
    return $self;  	
  }

  sub preparar {
    my $self = shift;
    my $key = shift;
    my $arg = shift;
    return $self->preparar_atributo($key) if not defined $arg;
    return $self->preparar_subcategoria($key, $arg);
  }

  sub atributos_nombres {
    my $self = shift;
    my $atributos = shift;
    return [map { $_->nombre } @$atributos];
  }

  sub sum {
    my $self = shift;
    my $atributos = shift;
    my $sum = 0;
    my $keys = $self->atributos_nombres($atributos);
    map {$sum += $self->estructura->{$_}} @$keys;
    return $sum;
  }

  sub preparar_subcategoria {
    my $self = shift;
    my $key = shift;
    my $valor = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my @filtrados;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      $self->estructura->{$key} = $atributo->validos->[0] if $atributo->validos;
      if ($self->personaje->$key) {
        $self->estructura->{$key} = $self->personaje->$key; 
        push @filtrados, $key;
      }
      if ($self->argumentos->{$key}) {
        $self->estructura->{$key} = $self->argumentos->{$key}; 
        push @filtrados, $key;
      }
    }
    my $sum = $self->sum($atributos);
    my $puntos = $valor - $sum;
    if($puntos < 0) {
      my $error = "El numero de puntos asignados ($sum) supera a los asignar ($valor)";
      Gaiman->logger->error($error);
      die $error;
    }
    while (1) {
      last if !$puntos;
      my $atributo = $atributos->[int rand scalar @$atributos];
      my $key = $atributo->nombre;
      if (scalar grep {$_ eq $key} @filtrados) {
        Gaiman->logger->trace("Se filtra el atributo $key por tener valor previo");
        next;
      }
      my $valor = $self->estructura->{$key};
      $valor += 1;
      if (!$atributo->validar($valor)) {
        Gaiman->logger->trace("No se valido el valor $valor para $key");
        next;
      }
      $self->estructura->{$key} = $valor;
      $puntos--;
    }
  }


  sub preparar_atributo {
    my $self = shift;
  	my $key = shift;
    my $atributo = Universo->actual->atributo_tipo($key);
    my $valor;
    if ($self->personaje->$key) {
      if ($self->personaje->$key ne 'NONAME') {
        $valor = $self->personaje->$key;
      }
    }
    if (exists $self->argumentos->{$key}){
      $valor = $self->argumentos->{$key};
      if(!$atributo->validar($valor)) {
        my $warn = "No es valido el valor $valor para el atributo $key";
        Gaiman->logger->warn($warn);
        warn $warn;
        $valor = undef;
      }
    }
    if (!$valor) {
      $valor = $atributo->alguno($self->estructura);
    }
  	$self->estructura->{$key} = $valor if defined $valor;
  }

  sub asignar {
    my $self = shift;
    foreach my $key (keys %{$self->estructura}) {
      my $valor = $self->estructura->{$key};
      $self->personaje->$key($valor) if $valor ne $self->personaje->$key;   
    }
    Gaiman->logger->info('Se construyo ', $self->personaje->name, ': ', $self->personaje->json);
  }
1;