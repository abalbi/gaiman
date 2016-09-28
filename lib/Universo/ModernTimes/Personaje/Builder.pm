package ModernTimes::Personaje::Builder;
use fields qw(_personaje _argumentos _estructura);
use strict;
use Data::Dumper;
use JSON;
our $actual;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->clean;

    $logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub personaje {
    my $self = shift;
  	my $valor = shift;
  	$self->{_personaje} = $valor if defined $valor;
    $self->{_personaje} = ModernTimes::Personaje->new if !$self->{_personaje};
  	return $self->{_personaje};
  }

  sub estructura {
    my $self = shift;
    my $valor = shift;
    if (!$self->{_estructura}) {
      $self->{_estructura} = ModernTimes::Personaje::Builder::Estructura->new;
      $self->{_estructura}->builder($self);
    }
    return $self->{_estructura};
  }

  sub argumentos {
    my $self = shift;
  	my $valor = shift;
  	$self->{_argumentos} = $valor if defined $valor;
  	return $self->{_argumentos};
  }

  sub clean {
    my $self = shift;
    $self->{_personaje} = undef;
    $self->{_argumentos} = {};
    $self->{_estructura} = ModernTimes::Personaje::Builder::Estructura->new;
    $self->{_estructura}->builder($self);
    return $self;    
  }

  sub build {
    my $self = shift;
    my $args = shift;
    $self->argumentos($args);
    $logger->info('[ARGS] '.Gaiman->l($args));
    $self->estructura->clean;
    $self->preparar('profesion');
    $self->preparar('sex');
    $self->preparar('age');
    $self->preparar('date_birth');
    $self->preparar('name');
    $self->preparar('virtues', 7);
    $self->preparar('background', 7);
    $self->preparar('attribute', [7,5,3]);
    $self->preparar('ability', [13,9,5]);
    $self->preparar('body');
    $self->preparar('description');
    $self->asignar;
    $self->crear_eventos;
    Entorno->actual->agregar($self->personaje);
    return $self;
  }

  sub crear_eventos {
    my $self = shift;
    my $atributos = Universo->actual->atributo_tipos;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      if($self->personaje->$key) {
        my $eventos = $atributo->crear_eventos($self->personaje);
        $logger->trace('crear_eventos: ', $key);
      }
    }

  }

  sub preparar {
    my $self = shift;
    my $key = shift;
    my $arg = shift;
    return $self->preparar_categoria($key, $arg) if Universo->es_catetoria($key);
    return $self->preparar_atributo($key) if not defined $arg;
    return $self->preparar_subcategoria($key, $arg) if defined $arg && not ref $arg;
  }


  sub atributos_nombres {
    my $self = shift;
    my $atributos = shift;
    return [sort map { $_->nombre } @$atributos];
  }

  sub preparar_categoria {
    my $self = shift;
    my $categoria = shift;
    my $valores = shift;
    my $subcategorias = Universo->actual->subcategorias($categoria);
    my $hash;
    if(Universo->actual->distribuye_puntos($categoria)) {
      foreach my $subcategoria (@$subcategorias) {
        my $libres = $self->estructura->libres($subcategoria);
        my $preseteados = $self->estructura->preseteados($subcategoria);
        $hash->{$subcategoria}->{posibles} = [grep {$_ > $preseteados} @$valores];
        $hash->{$subcategoria}->{libres} = $libres;
        $hash->{$subcategoria}->{preseteados} = $preseteados;
        $logger->logconfess("La subcategoria ",$subcategoria," tiene preseteados ", $preseteados, " punto y ninguno de los valores posibles ", Gaiman->l($valores)," puede ser aplicado.") if not scalar @{$hash->{$subcategoria}->{posibles}};
      }
      foreach my $subcategoria (sort {scalar(@{$hash->{$a}->{posibles}}) <=> scalar(@{$hash->{$b}->{posibles}})} @$subcategorias) {
        my $puntos = $hash->{$subcategoria}->{posibles}->[int rand scalar @{$hash->{$subcategoria}->{posibles}}];
        $logger->info(
          '[CATEGORIA] ', $subcategoria,
          ' posibles: ', Gaiman->l($hash->{$subcategoria}->{posibles}),
          ' libres: ', Gaiman->l($hash->{$subcategoria}->{libres}),
          ' preseteados: ', Gaiman->l($hash->{$subcategoria}->{preseteados}),
        );
        foreach my $subcat (@$subcategorias) {
          next if $subcat eq $subcategoria;
          $hash->{$subcat}->{posibles} = [grep {$_ ne $puntos} @{$hash->{$subcat}->{posibles}}];
        }
      }
      
    }
    foreach my $subcategoria (@$subcategorias) {
      $self->preparar_subcategoria($subcategoria, $hash->{$subcategoria}->{posibles}->[0]);
    }
  }

  sub preparar_subcategoria {
    my $self = shift;
    my $subcategoria = shift;
    my $puntos = shift;
    my $atributos = Universo->actual->atributo_tipo($subcategoria);
    $logger->info('[SUBCATEROGIA] ',$subcategoria,' -> ',Gaiman->l($puntos));
    if(Universo->actual->distribuye_puntos($subcategoria)) {

      my $count = $puntos - $self->estructura->preseteados($subcategoria);
      $logger->info('[SUBCATEROGIA] preseteados: ',Gaiman->l($self->estructura->preseteados($subcategoria)));
      $logger->info('[SUBCATEROGIA] count: ',Gaiman->l($count));
      my $c;
      $logger->logconfess("El numero de puntos (",Gaiman->l($puntos),") es menor que los preseteados (", Gaiman->l($self->estructura->preseteados($subcategoria)),")") if $count < 0;
      while (1) {
        $c++;
        die "Recusion infinita" if $c == 15;
        my $atributo = $atributos->[int rand scalar @$atributos];
        my $nombre = $atributo->nombre;
        my $val = $self->estructura->$nombre;
        my $new = $val + 1;
        if($atributo->validar($new) && !$self->estructura->es_previo($nombre)) {
          $self->preparar_atributo($nombre,$new);
          $count--;
        } else {
          $new = $val;
        }
        my $sum = $self->estructura->sum($subcategoria);
        my $libres = $self->estructura->libres($subcategoria);
        $logger->trace(
          "[SUBCATEROGIA] ",$nombre,
          $self->estructura->es_previo($nombre) ? '(PREVIO)':'', 
          Gaiman->l($val), '->', $new,
          ' sum:', $sum,
          ' libres:', $libres,
          ' puntos:', $count, '/', $puntos,
          ' preseteados:',$self->estructura->preseteados($subcategoria)
        );
        next if $count;
        last;
      }
    } else {
      foreach my $atributo (@$atributos) {
        my $nombre = $atributo->nombre;
        $self->preparar_atributo($nombre);

      }
    }
  }

  sub preparar_atributo {
    my $self = shift;
    my $key = shift;
    my $valor_parametro = shift;
    my $valor = $valor_parametro;
    my $atributo = Universo->actual->atributo_tipo($key);
    $self->estructura->$key($valor) if defined $valor;
    if($atributo->es_vacio($self->estructura->$key)) {
      $self->estructura->$key($atributo->alguno($self));
    }
    $atributo->aplicar_alteraciones($self, $valor_parametro);
    return;
  }

  sub asignar {
    my $self = shift;
    foreach my $key (sort keys %{$self->estructura->atributos}) {
      next if $key eq 'hash';
      my $valor = $self->estructura->$key;
      $logger->warn($valor) if ref $valor;
      $self->personaje->$key($valor) if $valor ne $self->personaje->$key;   
    }
    $logger->info('Se construyo ', $self->personaje->name, ': ', $self->personaje->json);
  }
1;

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

  sub sum {
    my $self = shift;
    my $key = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    my $sum = 0;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      $sum += $self->$nombre;
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
    return 1 if exists $self->builder->argumentos->{$key} || $self->builder->personaje->$key;
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
    my $caller = [caller(2)]->[3];
    my $parametro = shift;
    my $original = $self->{_atributos}->{$key};
    my $valor = $self->{_atributos}->{$key};
    my $atributo = Universo->actual->atributo_tipo($key);
    if(defined $parametro) {
      if(!$atributo->es_vacio($parametro)) {
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