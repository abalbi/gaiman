package ModernTimes::Atributo::Tipo;
use strict;
use fields qw(_nombre _validos _posibles _subcategoria _categoria _alguno _crear_eventos);
use Data::Dumper;
use JSON;

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self->{_nombre} = $args->{nombre};
	$self->{_validos} = $args->{validos};
	$self->{_posibles} = $args->{posibles};
	$self->{_subcategoria} = $args->{subcategoria};
	$self->{_categoria} = $args->{categoria};
  $self->{_alguno} = $args->{alguno};
  $self->{_crear_eventos} = $args->{crear_eventos};
	Gaiman->logger->trace("Se instancio ",ref $self);
	return $self;
}

sub es {
	my $self = shift;
	my $key = shift;
	return 1 if $self->nombre eq $key;
	return 1 if $self->subcategoria eq $key;
	return 1 if $self->categoria eq $key;
	return 0;
}

sub nombre {
  my $self = shift;
  return $self->{_nombre};
}

sub build {
  my $self = shift;
  return $self->{_build};
}

sub categoria {
  my $self = shift;
  return $self->{_categoria};
}

sub subcategoria {
  my $self = shift;
  return $self->{_subcategoria};
}

sub validos {
  my $self = shift;
  return $self->{_validos};
}

sub posibles {
  my $self = shift;
  my $contexto = shift;
  if(defined $contexto) {
    return &{$self->{_posibles}}($self,$contexto);
  }
  return $self->{_posibles};
}


sub validar {
  my $self = shift;
  my $valor = shift;
  return 1 if !$self->validos;
  return 1 if scalar @{$self->validos} eq 0;
  return 1 if scalar grep {$_ eq $valor} @{$self->validos};
	return 0;
}

sub alguno {
  my $self = shift;
  my $contexto = shift;
  if($self->{_alguno}) {
  	return &{$self->{_alguno}}($self, $contexto);
  }
	if($self->validos) {
		my $valor = $self->validos->[int rand scalar @{$self->validos}];
		return $valor;
	}
	if($self->posibles) {
		my $valor = $self->posibles($contexto)->[int rand scalar @{$self->posibles($contexto)}];
		return $valor;
	}
	return undef;
}

sub crear_eventos {
  my $self = shift;
  my $contexto = shift;
  if($self->{_crear_eventos}) {
    my $eventos = &{$self->{_crear_eventos}}($self, $contexto);
    return $eventos;
  }
  return undef;    
}

sub valor {
  my $self = shift;
  my $personaje = shift;
  my $valor = shift;
  return $valor;
}

sub es_vacio {
  my $self = shift;
  my $valor = shift;
  return not defined $valor;  
}

sub preparar_para_build {
  my $self = shift;
  my $builder = shift;
  my $parametro = shift;
  my $estructura = $builder->estructura;
  my $argumentos = $builder->argumentos;
  my $personaje = $builder->personaje;
  my $valor_random;
  my $valor;
  my $nombre = $self->nombre;
  $valor = $parametro;
  if (exists $argumentos->{$nombre}){
    if(ref $argumentos->{$nombre} eq 'ARRAY') {
      $valor = $argumentos->{$nombre}->[int rand scalar @{$argumentos->{$nombre}}];
    } else {
      $valor = $argumentos->{$nombre};
    }
  }
  if ($personaje->$nombre) {
    if ($personaje->$nombre ne 'NONAME') {
      $valor = $personaje->$nombre;
    }
  }
  $builder->estructura->{$nombre} = $valor;
  if ($self->es_vacio($valor)) {
    $valor_random = $self->alguno($estructura);
    $valor = $valor_random
  }
  if(!$self->validar($valor)) {
    Gaiman->warn("No es valido el valor $valor para el atributo ", $self->nombre);
    $valor = undef;
  }
  $builder->estructura->{$nombre} = $valor;
  Gaiman->logger->trace("preparar_atributo ",$self->nombre,": ", $valor ? $valor : 'NULO', ' -> ',encode_json({
    parametro => $parametro,
    argumentos => $argumentos->{$nombre},
    personaje => $personaje->$nombre,
    random => $valor_random,
  }));
  return $valor;
}
1;