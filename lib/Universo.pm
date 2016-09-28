package Universo;
use Data::Dumper;
use fields qw(_atributo_tipos _evento_tipos _builder_personaje _builder_evento _cache);

our $logger = Log::Log4perl->get_logger(__PACKAGE__);

our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $logger->info("Se instancio ",ref $self);
    $self->{_atributo_tipos} = [];
    $self->{_evento_tipos} = [];
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
    return $self->{_cache}->{$key} if exists $self->{_cache}->{$key};
  	foreach my $atributo_tipo (@{$self->atributo_tipos}) {
  		push @{$atributo_tipos}, $atributo_tipo if $atributo_tipo->es($key);
  	}
  	if(scalar @{$atributo_tipos} == 1) {
      $self->{_cache}->{$key} = $atributo_tipos->[0];
      return $atributo_tipos->[0];
    }
  	return $atributo_tipos;
  }

  sub atributo_tipos {
  	my $self = shift;
  	return $self->{_atributo_tipos};
  }

  sub evento_tipo {
    my $self = shift;
    my $key = shift;
    my $evento_tipos = [];
    foreach my $evento_tipo (@{$self->evento_tipos}) {
      push @{$evento_tipos}, $evento_tipo if $evento_tipo->es($key);
    }
    return $evento_tipos->[0] if scalar @{$evento_tipos} == 1;
    return $evento_tipos;
  }


  sub evento_tipos {
    my $self = shift;
    return $self->{_evento_tipos};
  }


  sub es_catetoria {
    my $self = shift;
    return $self->actual->es_catetoria(@_);
  }
1;