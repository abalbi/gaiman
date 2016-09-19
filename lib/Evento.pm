package Evento;
use strict;
use JSON;
use fields qw(_tipo _roles _epoch _name);
our $AUTOLOAD;
use Data::Dumper;
	sub new {
		my $self = shift;
		my $args = shift;
		$self = fields::new($self);
		return $self;
	}

	sub nombre {
		my $self = shift;
    return $self->tipo->nombre;
	}

  sub tipo {
    my $self = shift;
    my $tipo = shift;
    $self->{_tipo} = $tipo if defined $tipo;
    return $self->{_tipo};
  }

  sub name {
    my $self = shift;
    my $name = shift;
    $self->{_name} = $name if defined $name;
    return $self->{_name};
  }


  sub epoch {
    my $self = shift;
    my $epoch = shift;
    $self->{_epoch} = $epoch if defined $epoch;
    return $self->{_epoch};
  }

  sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    $method =~ s/.*:://;
    my $rol = $method if grep {$_ eq $method} @{$self->tipo->roles};
    if($rol) {
      return $self->rol($rol,@_);
    }
    die "No existe el metodo o rol '$method'";
  }

  sub rol {
    my $self = shift;
    my $key = shift;
    my $valor = shift;
    $self->{_roles}->{$key} = $valor if $valor;
    return $self->{_roles}->{$key};
  }

  sub roles {
    my $self = shift;
    return $self->{_roles};
  }

  sub description {
    my $self = shift;
    return $self->tipo->description($self);
  }
1;