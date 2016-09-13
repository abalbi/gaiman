package Universo;
use Data::Dumper;
use fields qw(_atributo_tipos _builder_personaje _builder_evento);

our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    Gaiman->logger->info("Se instancio ",ref $self);
    $self->{_atributo_tipos} = [];
    $self->init;
    $actual = $self;
    return $self;
  }

  sub actual {
  	my $class = shift;
  	return $actual;
  }

  sub atributo_tipo {
  	my $self = shift;
  	my $key = shift;
  	my $atributo_tipos = [];
  	foreach my $atributo_tipo (@{$self->atributo_tipos}) {
  		push @{$atributo_tipos}, $atributo_tipo if $atributo_tipo->es($key);
  	}
  	return $atributo_tipos->[0] if scalar @{$atributo_tipos} == 1;
  	return $atributo_tipos;
  }

  sub atributo_tipos {
  	my $self = shift;
  	return $self->{_atributo_tipos};
  }

  sub atributo_tipo_nombres {
    my $self = shift;
    return [map {$_->nombre} @{$self->atributo_tipos}];    
  }

  sub es_catetoria {
    my $self = shift;
    return $self->actual->es_catetoria(@_);
  }
1;