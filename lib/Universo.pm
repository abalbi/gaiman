package Universo;
use Data::Dumper;
use fields qw(_atributo_tipos _evento_tipos _builder_personaje _builder_evento _cache);

use Exporter qw(import);
our @ISA =   qw(Exporter);
our @EXPORT = ( qw(son es tienen tiene altera El Alteramos) );

our $logger = Log::Log4perl->get_logger(__PACKAGE__);
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $logger->info("Se instancio ",ref $self);
    $actual = $self;
    $self->{_atributo_tipos} = [];
    $self->{_evento_tipos} = [];
    $self->init;
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

  sub es_subcatetoria {
    my $self = shift;
    return $self->actual->es_subcatetoria(@_);
  }

  sub es_atributo {
    my $self = shift;
    return $self->actual->es_atributo(@_);
  }

  sub Alteramos {
    my $atributo = shift;
    my $keys = shift;
    my $arg = shift;
    $keys = [$keys] if ref $keys ne 'ARRAY';
    my $atributo = Universo->actual->atributo_tipo($atributo);
    foreach my $key (@$keys) {
      push @{$atributo->validos}, $key if !scalar grep {$_ eq $key} @{$atributo->validos};
      $atributo->alteraciones->{$key} = {} if !exists $atributo->alteraciones->{$key};
      my $hash = $atributo->alteraciones->{$key};
      if(exists $arg->{es}) {
        my $es = $arg->{es};
        my $alter_padre = {%{$atributo->alteraciones->{$es}}};
        foreach my $key (keys %{$arg->{alteraciones}}) {
          $alter_padre->{$key} = $arg->{alteraciones}->{$key}
        }
        $arg->{alteraciones} = $alter_padre;
      }
      if(exists $arg->{alteraciones}) {
        foreach my $key (keys %{$arg->{alteraciones}}) {
          $hash->{$key} = $arg->{alteraciones}->{$key}
        }
      }
    }
  }

  sub El { }

  sub es {
    my $hash->{es} = shift;
    return $hash;
  }

  sub son {
    return es(@_);
  }

  sub tienen {
    return altera(@_);
  }

  sub tiene {
    return altera(@_);
  }

  sub altera {
    my $hash->{alteraciones} = {@_};
    return $hash;
  }


1;