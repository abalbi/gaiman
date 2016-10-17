package ModernTimes::Atributo::Tipo::Hash;
use strict;
use base qw(ModernTimes::Atributo::Tipo);
use fields qw(_requeridos);
use Data::Dumper;
use JSON;
use Term::ANSIColor;

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

sub es_hash { 1 };

sub defecto {
  my $self = shift;
  return {};  
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

sub detalle {
  my $self = shift;
  my $valor = shift;
  my $str = [];
  foreach my $key (keys %$valor) {
    push @$str, sprintf("%s: %s", colored($key, 'BOLD'), $valor->{$key});
  }
  return join "; ", @$str;
}


1;