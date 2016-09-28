package ModernTimes::Atributo::Tipo::Puntos;
use strict;
use base qw(ModernTimes::Atributo::Tipo);
use fields qw();
use Data::Dumper;

sub min {
	my $self = shift;
  return $self->validos->[0];
}

sub max {
	my $self = shift;
  return $self->validos->[$#{$self->validos}];
}

sub alguno {
  my $self = shift;
  my $builder = shift;
  my $valor = shift;
  if (defined $valor) {
    return $valor->[int rand scalar @{$valor}];
  }
  return $self->SUPER::alguno();
}

sub defecto {
  my $self = shift;
  return  $self->validos->[0]; 
}

1;