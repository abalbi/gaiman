package ModernTimes::Personaje::Builder;
use fields qw(_personaje _argumentos _estructura _comandos);
use strict;
use Data::Dumper;
use JSON;
our $actual;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->clean;

    $logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub personaje {
    my $self = shift;
  	my $valor = shift;
  	$self->{_personaje} = $valor if defined $valor;
    $self->{_personaje} = ModernTimes::Personaje->new if !$self->{_personaje};
  	return $self->{_personaje};
  }

  sub estructura {
    my $self = shift;
    my $valor = shift;
    if (!$self->{_estructura}) {
      $self->{_estructura} = ModernTimes::Personaje::Builder::Estructura->new;
      $self->{_estructura}->builder($self);
    }
    return $self->{_estructura};
  }

  sub argumentos {
    my $self = shift;
  	my $valor = shift;
  	$self->{_argumentos} = $valor if defined $valor;
  	return $self->{_argumentos};
  }

  sub clean {
    my $self = shift;
    $self->{_personaje} = undef;
    $self->{_argumentos} = {};
    $self->{_comandos} = [];
    $self->{_estructura} = ModernTimes::Personaje::Builder::Estructura->new;
    $self->{_estructura}->builder($self);
    return $self;    
  }

  sub build {
    my $self = shift;
    my $args = shift;
    $self->argumentos($args);
    $logger->info('[ARGS] '.Gaiman->l($args));
    $self->estructura->clean;
    $self->comando_carga('concept');
    $self->comando_carga('profesion');
    $self->comando_carga('sex');
    $self->comando_carga('age');
    $self->comando_carga('date_birth');
    $self->comando_carga('name');
    $self->comando_carga('virtues', 7);
    $self->comando_carga('background', 7);
    $self->comando_carga('attribute', [7,5,3]);
    $self->comando_carga('ability', [13,9,5]);
    $self->comando_carga('body');
    $self->comando_carga('description');
    $self->hacer;
    $self->asignar;
    $self->crear_eventos;
    Entorno->actual->agregar($self->personaje);
    return $self;
  }

  sub hacer {
    my $self = shift;
    foreach my $comando (@{$self->comandos}) {
      $comando->hacer if !$comando->hecho;
    }     
  }

  sub comando_carga {
    my $self = shift;
    my $key = shift;
    my $puntos = shift;
    my $comando;
    $comando = ModernTimes::Personaje::Builder::Comando::Categoria->new($key, $puntos) if Universo->es_catetoria($key);
    $comando = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, $puntos) if Universo->es_subcatetoria($key);
    $comando = ModernTimes::Personaje::Builder::Comando::Atributo->new($key, $puntos) if Universo->es_atributo($key);
    $comando->builder($self);
    push @{$self->comandos}, $comando;
    return $self;    
  }

  sub comandos {
    my $self = shift;
    return $self->{_comandos};
  }

  sub comando_ultimo {
    my $self = shift;
    return $self->{_comandos}->[$#{$self->{_comandos}}];
  }

  sub crear_eventos {
    my $self = shift;
    my $atributos = Universo->actual->atributo_tipos;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      if($self->personaje->$key) {
        my $eventos = $atributo->crear_eventos($self->personaje);
        $logger->trace('crear_eventos: ', $key);
      }
    }

  }


  sub atributos_nombres {
    my $self = shift;
    my $atributos = shift;
    return [sort map { $_->nombre } @$atributos];
  }


  sub asignar {
    my $self = shift;
    foreach my $key (sort keys %{$self->estructura->atributos}) {
      next if $key eq 'hash';
      my $valor = $self->estructura->$key;
      $self->personaje->$key($valor) if $valor ne $self->personaje->$key;   
    }
    $logger->info('Se construyo ', $self->personaje->name, ': ', $self->personaje->json);
  }
1;

