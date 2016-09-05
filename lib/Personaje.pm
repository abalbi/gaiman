package Personaje;
use strict;
use JSON;
use fields qw(_atributos);
our $AUTOLOAD;
use Data::Dumper;
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
    $method =~ s/_(tipo)$//;
    my $tipo = $1;
    my $atributo = $method if grep {$_->nombre eq $method} @{Universo->actual->atributo_tipos};
    if($atributo) {
      return $self->{_atributos}->{$atributo}->{tipo} if $tipo;
      return $self->atributo($atributo,@_);
    }
    die "No existe el metodo o atributo '$method'";
  }

  sub atributo {
  	my $self = shift;
    my $key = shift;
    my $valor = shift;
    if(defined $valor) {
      $self->{_atributos}->{$key} = {
        tipo => Universo->actual->atributo_tipo($key),
        valor => undef
      } if !exists $self->{_atributos}->{$key};
      $self->{_atributos}->{$key}->{valor} = $valor; 
      Gaiman->logger->trace("Se asigno ",$self->name,": ",encode_json({$key => $valor}));
    }
    return 'NONAME' if $key eq 'name' &&  !$self->{_atributos}->{$key}->{valor};
    return $self->{_atributos}->{$key}->{valor};
  }

  sub atributos {
    my $self = shift;
    return $self->{_atributos};
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