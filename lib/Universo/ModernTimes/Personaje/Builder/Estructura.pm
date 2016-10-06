package ModernTimes::Personaje::Builder::Estructura;
our $AUTOLOAD;
use Data::Dumper;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);

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
      $hash->{$nombre} = $self->$nombre;
    }
    return $hash;
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

  sub validar_punto_vs_libres {
    my $self = shift;
    my $key = shift;
    my $puntos = shift;
    if ($puntos > $self->sum_libres($key)) {
      return 0;
    } 
    return 1;
  }

  sub validar_punto_vs_preseteados {
    my $self = shift;
    my $key = shift;
    my $puntos = shift;
    if ($puntos < $self->sum_preseteados($key)) {
      return 0;
    } 
    return 1;
  }

  sub sum_preseteados {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = $self->sum($key);
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum -= $atributo->defecto;
    }
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
      $sum += $self->$nombre;
    }
    return $sum;

  }

  sub sum_libres {
    my $self = shift;
    my $key = shift;
    my $atributos = $self->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum -= $self->$nombre if !$self->es_previo($nombre);
      $sum += $atributo->max;
      $sum -= $atributo->max if $self->es_previo($nombre); 
    }
    return $sum;
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
      $self->{_tipos}->{$nombre} = ModernTimes::Personaje::Builder::Estructura::Atributo->new($tipo) if !$self->{_tipos}->{$nombre};
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
    my $caller = [caller(2)]->[3].":".[caller(1)]->[2];
    my $parametro = shift;
    my $original = $self->{_atributos}->{$key};
    my $valor = $self->{_atributos}->{$key};
    my $atributo = $self->atributo_tipo($key);
    if(defined $parametro) {
      if(!$atributo->validar($parametro)) {
        $logger->logwarn("No es valido el valor ".Gaiman->l($parametro)." para el atributo ", $atributo->nombre);
      } else {
        $valor = $parametro;
        if(ref $valor eq 'ARRAY') {
          my $lista = Gaiman->l($valor);
          $valor = $valor->[int rand scalar @$valor];
          $logger->trace("$key => parametro RANDOM: ".Gaiman->l($lista)." -> ".Gaiman->l($valor)." desde $caller");
        }
        $self->{_atributos}->{$key} = $valor;
        $logger->trace("$key => parametro: ".Gaiman->l($original)." -> ".Gaiman->l($valor)." desde $caller");
        return $self->{_atributos}->{$key};
      }
    }
 
    if (!$atributo->es_vacio($self->{_atributos}->{$key})) {
      $valor = $self->{_atributos}->{$key};
      $logger->trace("$key => estructura: ".Gaiman->l($original)." -> ".Gaiman->l($valor)." desde $caller");
      return $self->{_atributos}->{$key} ;
    }
    
    if(exists $self->builder->argumentos->{$key}) {
      my $valor = $self->builder->argumentos->{$key};
      if(!$atributo->validar($valor) && !$atributo->es_vacio($valor)) {
        $logger->logwarn("No es valido el valor $valor para el atributo ", $atributo->nombre);
      } else {
        if(ref $valor eq 'ARRAY') {
          my $lista = Gaiman->l($valor);
          $valor = $valor->[int rand scalar @$valor];
          $logger->info("$key => argumento RANDOM: ".Gaiman->l($lista)." -> ".Gaiman->l($valor)." desde $caller");
        }
        $logger->trace("$key => argumento: ".Gaiman->l($original)." -> ".Gaiman->l($valor)." desde $caller");
        $self->{_atributos}->{$key} = $valor;
        return $self->{_atributos}->{$key};
      }
    }

    if (!$atributo->es_vacio($self->builder->personaje->$key)) {
      $valor = $self->builder->personaje->$key;
      $logger->trace("$key => personaje: ".Gaiman->l($original)." -> ".Gaiman->l($valor)." desde $caller");
    }
    if ($atributo->es_vacio($valor)) {
      $valor = $atributo->defecto;
      $logger->trace("$key => defecto: ".Gaiman->l($original)." -> ".Gaiman->l($valor)." desde $caller");
    }

    $self->{_atributos}->{$key} = $valor;
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

  sub validos {
    my $self = shift;
    my $valor = shift;
    if(defined $valor) {
      $self->{_validos} = $valor;  
    }
    return $self->{_validos} if exists $self->{_validos};
    return $self->{_tipo}->validos;    
  }
1;