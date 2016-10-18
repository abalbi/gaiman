package ModernTimes::Atributo::Tipo;
use strict;
use fields qw(_nombre _validos _posibles _subcategoria _categoria _alguno _crear_eventos _alteraciones);
use Data::Dumper;
use JSON;
use Gaiman::Util;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);


sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self->{_nombre} = $args->{nombre};
	$self->{_validos} = $args->{validos};
	$self->{_posibles} = $args->{posibles};
  $self->{_subcategoria} = $args->{subcategoria};
  $self->{_alteraciones} = $args->{alteraciones};
	$self->{_categoria} = $args->{categoria};
  $self->{_alguno} = $args->{alguno};
  $self->{_crear_eventos} = $args->{crear_eventos};
	$logger->trace("Se instancio ",ref $self);
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
  $self->{_validos} = [] if !$self->{_validos};
  return $self->{_validos};
}

sub alteraciones {
  my $self = shift;
  $self->{_alteraciones} = {} if !$self->{_alteraciones};
  return $self->{_alteraciones};
}

sub posibles {
  my $self = shift;
  my $contexto = shift;
  if(defined $contexto) {
    return &{$self->{_posibles}}($self,$contexto);
  }
  return $self->validos if scalar @{$self->validos}; 
  return $self->{_posibles};
}

sub es_hash { 0 };

sub validar {
  my $self = shift;
  $logger->debug(Dumper [@_]);
  my $valor = shift;
  my $validos = shift;
  $validos = $self->validos if not defined $validos;
  my $valores = $valor;
  $valores = [$valor] if ref($valor) eq '';
  return 1 if !$self->validos;
  return 1 if scalar @{$validos} eq 0;
  my $boo = 1;
  foreach my $val (@$valores) {
    $logger->trace("A validar: ".Gaiman->l($val)." contra ".Gaiman->l($valores));
    if(!scalar grep {$_ eq $val} @{$validos}) {
      $boo = 0;
    }
  }
  return $boo;
}

sub alguno {
  my $self = shift;
  my $builder = shift;
  if($self->{_alguno}) {
    return &{$self->{_alguno}}($self, $builder, @_);
  }
  if(scalar @{$self->validos}) {
    my $valor = azar $self->validos;
    return $valor;
  }
	if($self->posibles) {
		my $valor = azar $self->posibles($builder);
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
  return 1 if $valor eq 'NONAME';
  return 1 if not defined $valor;
  return 0;  
}


sub defecto {
  my $self = shift;
  return undef;  
}

1;