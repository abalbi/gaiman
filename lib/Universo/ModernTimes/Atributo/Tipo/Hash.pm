package ModernTimes::Atributo::Tipo::Hash;
use strict;
use base qw(ModernTimes::Atributo::Tipo);
use fields qw(_requeridos);
use Data::Dumper;
use JSON;

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self = $self->SUPER::new($args);
	$self->{_requeridos} = $args->{requeridos};
	return $self;
}


sub valor {
  my $self = shift;
  my $personaje = shift;
  my $valor = shift;
  my $nombre = $self->nombre;
  if(not defined $valor) {
  	$valor = {};
  }
  return $valor;
}

sub es_vacio {
  my $self = shift;
  my $valor = shift;
  return 0 if scalar(grep {exists $valor->{$_}} @{$self->requeridos}) == scalar @{$self->requeridos};
  return 1;  
}

sub requeridos {
  my $self = shift;
  return $self->{_requeridos};
}

sub preparar_para_build {
  my $self = shift;
  my $estructura = shift;
  my $argumentos = shift;
  my $personaje = shift;
  my $parametro = shift;
  my $valor_random;
  my $valor = {};
  my $nombre = $self->nombre;
  if (exists $argumentos->{$nombre}){
    foreach my $key (sort keys %{$argumentos->{$nombre}}) {
      $valor->{$key} = $argumentos->{$nombre}->{$key};
    }
  }
  Gaiman->logger->debug("preparar_atributo ",$self->nombre,": ",encode_json({
    parametro => $parametro,
    argumentos => $argumentos->{$nombre},
    personaje => $personaje->$nombre,
    random => $valor_random,
    final => $valor,
  }));
  if ($personaje->$nombre) {
    if ($personaje->$nombre ne 'NONAME') {
      foreach my $key (sort keys %{$personaje->$nombre}) {
        $valor->{$key} = $personaje->$nombre->{$key} if defined $personaje->$nombre->{$key};
      }
    }
  }
  if ($self->es_vacio($valor)) {
    $valor_random = $self->alguno($valor);
    $valor = $valor_random
  }
  if(!$self->validar($valor)) {
    Gaiman->warn("No es valido el valor $valor para el atributo ", $self->nombre);
    $valor = undef;
  }
  Gaiman->logger->trace("preparar_atributo ",$self->nombre,": ",encode_json({
    parametro => $parametro,
    argumentos => $argumentos->{$nombre},
    personaje => $personaje->$nombre,
    random => $valor_random,
    final => $valor,
  }));
  return $valor;
}
1;