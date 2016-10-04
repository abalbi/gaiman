package ModernTimes::Personaje::Builder::Estructura;
our $AUTOLOAD;
use Data::Dumper;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);

use fields qw(_atributos _builder _hash);
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    return $self;
  }

  sub hash {
    my $self = shift;
    $self->{_hash} = {} if !$self->{_hash};
    return $self->{_hash};
  }

  sub valores {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $hash;
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $hash->{$nombre} = $self->$nombre;
    }
    return $hash;
  }

  sub sum {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    $atributos = [$atributos] if ref $atributos ne 'ARRAY';
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum += $self->$nombre;
    }
    return $sum;

  }

  sub asignados {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum += $self->sum($nombre) - $atributo->defecto;
    }
    return $sum;

  }

  sub defecto {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      $sum += $atributo->defecto;
    }
    return $sum;
  }

  sub libres {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum -= $self->$nombre if !$self->es_previo($nombre);
      $sum += $atributo->max;
      $sum -= $atributo->max if $self->es_previo($nombre); 
    }
    return $sum;
  }

  sub preseteados {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $sum = $self->sum($key);
    foreach my $atributo (@$atributos) {
      $sum -= $atributo->defecto;
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
    my $atributo = $method;
    if($atributo) {
      return $self->atributo($atributo,@_);
    }
    Gaiman->error("No existe el metodo o atributo '$method'");
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
    my $atributo = Universo->actual->atributo_tipo($key);
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