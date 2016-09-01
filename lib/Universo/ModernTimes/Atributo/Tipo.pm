package ModernTimes::Atributo::Tipo;
use strict;
use fields qw(_nombre _validos _posibles);

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
  $self->{_nombre} = $args->{nombre};
  $self->{_validos} = $args->{validos};
  $self->{_posibles} = $args->{posibles};
	Gaiman->logger->trace("Se instancio ",ref $self);
	return $self;
}
sub es {
	my $self = shift;
	my $key = shift;
	return 1 if $self->nombre eq $key;
	return 0;
}

sub nombre {
  my $self = shift;
  return $self->{_nombre};
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
1;