package Personaje;
use strict;
use JSON;
use fields qw(_atributos _eventos);
our $AUTOLOAD;
use Data::Dumper;

our $logger = Log::Log4perl->get_logger(__PACKAGE__);

	sub new {
		my $self = shift;
		my $args = shift;
		$self = fields::new($self);
		return $self;
	}

	sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    $method =~ s/.*:://;
    $method =~ s/_(tipo|detalle)$//;
    my $post = $1;
    my $atributo = $method if grep {$_->nombre eq $method} @{Universo->actual->atributo_tipos};
    if($atributo) {
      return $self->{_atributos}->{$atributo}->{tipo} if $post eq 'tipo';
      return $self->{_atributos}->{$atributo}->{tipo}->detalle($self->atributo($atributo)) if $post eq 'detalle';
      return $self->atributo($atributo,@_);
    }
    Gaiman->error("No existe el metodo o atributo '$method'");
  }

  sub atributo {
    my $self = shift;
    my $key = shift;
    my $valor = shift;
    $self->{_atributos}->{$key} = {
      tipo => undef,
      valor => undef
    } if !exists $self->{_atributos}->{$key};
    my $tipo = Universo->actual->atributo_tipo($key);
    $self->{_atributos}->{$key}->{tipo} = $tipo if !$self->{_atributos}->{$key}->{tipo};
    if(!$tipo->es_vacio($valor)) {
      if($tipo->validar($valor)) {
        $self->{_atributos}->{$key}->{valor} = $tipo->valor($self, $valor);
        $logger->trace("Se asigno ",$self->name,": ",encode_json({$key => $valor}));
      } else {
        $logger->logwarn("No es valido el valor ".Gaiman->l($valor)." para el atributo ", $tipo->nombre);
      }
    }
    $valor = $self->{_atributos}->{$key}->{valor};
    return 'NONAME' if $key eq 'name' &&  !$self->{_atributos}->{$key}->{valor};
    return $tipo->valor($self, $valor);
  }

  sub atributos {
    my $self = shift;
    return $self->{_atributos};
  }

  sub eventos {
    my $self = shift;
    $self->{_eventos} = [] if !$self->{_eventos};
    return $self->{_eventos};
  }

  sub es {
    my $self = shift;
    my $key = shift;
    return 1 if $self->name eq $key;
    return 0;
  }

  sub json {
    my $self = shift;
    my $hash = {};
    foreach my $key (sort keys %{$self->atributos}) {
      $hash->{$key} = $self->atributos->{$key}->{valor}; 
    }
    return encode_json($hash);
  }

1;