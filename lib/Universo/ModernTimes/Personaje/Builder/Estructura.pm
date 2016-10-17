package ModernTimes::Personaje::Builder::Estructura;
our $AUTOLOAD;
use Data::Dumper;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
use Carp(cluck);

use fields qw(_atributos _builder _hash _tipos);
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    return $self;
  }

  sub valores {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    $atributos = [$atributos] if ref $atributos ne 'ARRAY';
    my $hash = {};
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $hash->{$nombre} = $self->argumentos->{$nombre} if !$hash->{$nombre};
      $hash->{$nombre} = $self->personaje->$nombre if !$hash->{$nombre};
      $hash->{$nombre} = $self->$nombre if !$hash->{$nombre};
    }
    return $hash;
  }


  sub validar_punto_vs_libres {
    my $self = shift;
    my $key = shift;
    my $puntos = shift;
    if ($puntos > $self->sum_libres($key)) {
      return 0;
    } 
    return 1;
  }

  sub validar_punto_vs_preasignados {
    my $self = shift;
    my $key = shift;
    my $puntos = shift;
    if ($puntos < $self->sum_preasignados($key)) {
      return 0;
    } 
    return 1;
  }

  sub sum_libres {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum += $atributo->max;
      if($self->es_previo($nombre)) {
        $sum -= $atributo->max;      
      } else {
        if($self->$nombre) {
          $sum -= $self->$nombre;
        } else {
          $sum -= $atributo->defecto;
        }
      }
    }
    return $sum;
  }

  sub sum_defecto {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      $sum += $atributo->defecto;
    }
    return $sum;
  }

  sub sum_posibles {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $min = 0;
    my $max = 0;
    foreach my $atributo (@$atributos) {
      $min += $atributo->posibles->[0] - $atributo->defecto;
      $max += $atributo->posibles->[$#{$atributo->posibles}] - $atributo->defecto;
    }
    my $sum = [$min..$max];
    return $sum;
  }

  sub sum_preasignados {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      if($self->es_previo($nombre)) {
        $sum -= $atributo->defecto;
        if(exists $self->argumentos->{$nombre}) {
          return undef if ref $self->argumentos->{$nombre} ne '';
          $sum += $self->argumentos->{$nombre};
        } else {
          $sum += $self->personaje->$nombre if $self->personaje->$nombre;
        }
      }
    }
    $logger->trace("SUM PREASIGNADOS: ", join(' + ', map {$_->nombre} @{$atributos}), " = ", $sum);
    $sum = 0 if $sum < 0;
    return $sum;
  }

  sub sum_asignados {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = $self->sum($key);
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      if ($self->es_previo($nombre)) {
        $sum -= $self->personaje->$nombre if $self->personaje->$nombre;
        $sum -= $self->argumentos->{$nombre} if exists $self->argumentos->{$nombre};
      } else {
        $sum -= $atributo->defecto;
      }
    }
    $sum = 0 if $sum < 0;
    return $sum;
  }

  sub sum {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    $atributos = [$atributos] if ref $atributos ne 'ARRAY';
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      my $val = 0;
      $val = $self->argumentos->{$nombre} if !$val;
      $val = $self->personaje->$nombre if !$val;
      $val = $self->$nombre if !$val;
      $val = $atributo->defecto if !$val;
      return undef if ref $val ne '';
      $sum += $val;
      $logger->trace('SUM ',$nombre, ' => ', $val,
        ' personaje: ', Gaiman->l($self->personaje->$nombre),
        ' argumentos: ', Gaiman->l($self->argumentos->{$nombre}),
        ' estructura: ', Gaiman->l($self->$nombre),
      );
    }
    $logger->trace("SUM: ", join(' + ', map {$_->nombre} @{$atributos}), " = ", $sum);
    return $sum;
  }

  sub personaje {
    my $self = shift;
    return $self->builder->personaje;
  }

  sub argumentos {
    my $self = shift;
    return $self->builder->argumentos;
  }

  sub es_previo {
    my $self = shift;
    my $key = shift;
    return 1 if exists $self->builder->argumentos->{$key} || ($self->builder->personaje->$key && $self->builder->personaje->$key ne 'NONAME');
    return 0;
  }

  sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    $method =~ s/.*:://;
    my $atributo = $method if grep {$_->nombre eq $method} @{Universo->actual->atributo_tipos};;
    if($atributo) {
      return $self->atributo($atributo,@_);
    }
    $logger->logconfess("No existe el metodo o atributo '$method'");
  }

  sub atributo_tipo {
    my $self = shift;
    my $key = shift;
    my $tipos = Universo->actual->atributo_tipo($key);
    $tipos = [$tipos] if ref $tipos ne 'ARRAY';
    my $array = [];
    foreach my $tipo (@$tipos) {
      my $nombre = $tipo->nombre;
      if (!$self->{_tipos}->{$nombre}) {
        $self->{_tipos}->{$nombre} = ModernTimes::Personaje::Builder::Estructura::Atributo->new($tipo);
        $logger->trace("Se agrego al builder el atributo tipo ".Gaiman->l($nombre));
      }
      push @$array, $self->{_tipos}->{$nombre};
    }
    return $array->[0] if scalar @$array == 1;
    return $array;
  }

  sub atributos {
    my $self = shift;
    return $self->{_atributos};
  }

  sub atributo {
    my $self = shift;
    my $key = shift;
    my $parametro = shift;
    $logger->debug("Key: ", Gaiman->l($key), " Parametro: ", Gaiman->l($parametro) );
    my $atributo = $self->atributo_tipo($key);
    $self->{_atributos}->{$key} = $atributo->defecto if !exists $self->{_atributos}->{$key};
    if(defined $parametro) {
      $self->{_atributos}->{$key} = $parametro;
    }
    return $self->{_atributos}->{$key};
  }

  sub clean {
    my $self = shift;
    $self->{_atributos} = {};
    return $self;
  }

  sub builder {
    my $self = shift;
    my $valor = shift;
    $self->{_builder} = $valor if defined $valor;
    return $self->{_builder};
  }

1;

package ModernTimes::Personaje::Builder::Estructura::Atributo;
  our $AUTOLOAD;
  use fields qw(_tipo _validos);
  use Data::Dumper;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_tipo} = $args;
    return $self;
  }

  sub AUTOLOAD {
    my $method = $AUTOLOAD;
    my $self = shift;
    $method =~ s/.*:://;
    return $self->{_tipo}->$method(@_);
  }


  sub posibles {
    my $self = shift;
    my $contexto = shift;
    if(defined $contexto) {
      return $self->{_tipo}->posibles($self,$contexto);
    }
    return $self->validos if scalar @{$self->validos}; 
    return $self->posibles;
  }

  sub validos {
    my $self = shift;
    my $valor = shift;
    if(defined $valor) {
      $self->{_validos} = $valor;  
      $logger->trace("Se seteo validos para ".Gaiman->l($self->nombre)." : ".Gaiman->l($valor));
    }
    return $self->{_validos} if exists $self->{_validos};
    return $self->{_tipo}->validos;    
  }

  sub alguno {
    my $self = shift;
    my $builder = shift;
    if(scalar @{$self->validos}) {
      return $self->{_tipo}->alguno($builder, $self->validos, @_);
    } else {
      return $self->{_tipo}->alguno($builder,@_);
    }
  }

  sub validar {
    my $self = shift;
    my $valor = shift;
    return $self->{_tipo}->validar($valor, $self->validos);
  }

  sub es_hash {
    my $self = shift;
    return $self->{_tipo}->es_hash;
  }
1;