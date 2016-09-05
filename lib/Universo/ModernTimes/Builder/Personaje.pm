package ModernTimes::Builder::Personaje;
use fields qw(_personaje _argumentos _estructura);
use strict;
use Data::Dumper;
use JSON;
our $actual;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->{_argumentos} = {};
    Gaiman->logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub personaje {
    my $self = shift;
  	my $valor = shift;
  	$self->{_personaje} = $valor if defined $valor;
  	return $self->{_personaje};
  }

  sub estructura {
    my $self = shift;
    my $valor = shift;
    $self->{_estructura} = $valor if defined $valor;
    return $self->{_estructura};
  }

  sub argumentos {
    my $self = shift;
  	my $valor = shift;
  	$self->{_argumentos} = $valor if defined $valor;
  	return $self->{_argumentos};
  }

  sub build {
    my $self = shift;
    my $args = shift;
    $self->argumentos($args);
    $self->estructura({});
    $self->preparar('sex');
    $self->preparar('name');
    $self->preparar('virtues', 10);
    $self->preparar('attribute', [10,8,6]);
    $self->preparar('ability', [13,9,5]);
    $self->preparar('description');
    $self->asignar;
    return $self;  	
  }

  sub preparar {
    my $self = shift;
    my $key = shift;
    my $arg = shift;
    return $self->preparar_atributo($key) if not defined $arg;
    return $self->preparar_subcategoria($key, $arg) if defined $arg && not ref $arg;
    return $self->preparar_categoria($key, $arg) if defined $arg && ref $arg eq 'ARRAY';
  }


  sub atributos_nombres {
    my $self = shift;
    my $atributos = shift;
    return [sort map { $_->nombre } @$atributos];
  }

  sub sum {
    my $self = shift;
    my $atributos = shift;
    my $sum = 0;
    my $keys = $self->atributos_nombres($atributos);
    map {$sum += $self->estructura->{$_}} @$keys;
    return $sum;
  }


  sub preparar_categoria {
    my $self = shift;
    my $key = shift;
    my $valores = shift;
    my $temp = [@{$valores}];
    my $atributos = Universo->actual->atributo_tipo($key);
    my $hash = {};
    $self->preparar_categoria_minimos($hash,$atributos);
    $self->preparar_categoria_reducir_rangos($hash,$valores);
    $self->preparar_categoria_asignacion($hash, $temp);
    foreach my $key (sort keys %$hash) {
      $self->preparar_subcategoria($key, $hash->{$key}->{asignado});
    }
  } 

  sub preparar_categoria_asignacion {
    my $self = shift;
    my $hash = shift;
    my $temp = shift;
    my $ordenados = [sort {$b->{min} <=> $a->{min}} values %$hash];
    my $ordenados = [sort {$b->{subcategoria} cmp $a->{subcategoria}} values %$hash];
    foreach my $subcategoria (@$ordenados) { 
      my $asignado = $subcategoria->{rango}->[int rand scalar @{$subcategoria->{rango}}];
      my $temp2 = [grep {$asignado != $_} @$temp];
      if(scalar @$temp == scalar @$temp2) {
        my $error = "Se trata de asignar 2 veces el mismo valor a dos subcategorias distintas. Inaudito";
        Gaiman->logger->error($error);
        die $error;
      }
      $temp = $temp2;
      $subcategoria->{asignado} = $asignado;
      $subcategoria->{rango} = [];
      foreach my $subcat (sort {$a->{key} cmp $b->{key}} values %$hash) {
        next if $subcat->{asignado};
        $subcat->{rango} = [grep {$_ ne $subcategoria->{asignado}} @{$subcat->{rango}}];
      }
    }
    Gaiman->logger->trace('preparar_categoria: ASIGNACION: '.encode_json($hash));
  }

  sub preparar_categoria_reducir_rangos {
    my $self = shift;
    my $hash = shift;
    my $valores = shift;
    my $rangos_con_un_valor = 0;
    foreach my $key2 (sort keys %$hash) {
      my $subcategoria = $hash->{$key2};
      $subcategoria->{rango} = [grep {$_ >= $subcategoria->{min}} @$valores];
      $rangos_con_un_valor++ if scalar @{$subcategoria->{rango}} == 1;
      if(!scalar @{$subcategoria->{rango}}) {
        my $error = "Los puntos preasignados($subcategoria->{min}) estan fuera de rango (".join(',',@{$valores}).")";
        Gaiman->logger->error($error);
        die $error;
      }
    }
    Gaiman->logger->trace('preparar_categoria: RANGOS: '.encode_json($hash));
    if($rangos_con_un_valor > 1) {
      my $error = "Se encontraron 2 o mas subcategorias que solo pueden usar un valor. Esto es imposible";
      Gaiman->logger->error($error);
      die $error;
    }
  }

  sub preparar_categoria_minimos {
    my $self = shift;
    my $hash = shift;
    my $atributos = shift;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      $hash->{$atributo->subcategoria} = {min => 0, subcategoria => $atributo->subcategoria} if !$hash->{$atributo->subcategoria};
      if ($self->personaje->$key) {
        $hash->{$atributo->subcategoria}->{min} += $self->personaje->$key; 
      } else {
        if ($self->argumentos->{$key}) {
          $hash->{$atributo->subcategoria}->{min} += $self->argumentos->{$key}; 
        } else {
          $hash->{$atributo->subcategoria}->{min} += $atributo->validos->[0];
        }
      }
    }
    Gaiman->logger->trace('preparar_categoria: MINIMOS: '.encode_json($hash));
  }


  sub preparar_subcategoria {
    my $self = shift;
    my $key = shift;
    my $valor = shift;
    if(!$valor) {
      my $error = "No se puede preparar una subcategoria si no se pasa un valor";
      Gaiman->logger->error($error);
      die $error;
    }
    my $atributos = Universo->actual->atributo_tipo($key);
    my @filtrados;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      $self->estructura->{$key} = $atributo->validos->[0] if $atributo->validos;
      if ($self->personaje->$key) {
        $self->estructura->{$key} = $self->personaje->$key; 
        push @filtrados, $key;
      }
      if ($self->argumentos->{$key}) {
        $self->estructura->{$key} = $self->argumentos->{$key}; 
        push @filtrados, $key;
      }
    }
    my $sum = $self->sum($atributos);
    my $puntos = $valor - $sum;
    if($puntos < 0) {
      my $error = "El numero de puntos asignados ($sum) supera a los asignar ($valor)";
      Gaiman->logger->error($error);
      die $error;
    }
    while (1) {
      last if !$puntos;
      my $atributo = $atributos->[int rand scalar @$atributos];
      my $key = $atributo->nombre;
      if (scalar grep {$_ eq $key} @filtrados) {
        Gaiman->logger->trace("Se filtra el atributo $key por tener valor previo");
        next;
      }
      my $valor = $self->estructura->{$key};
      $valor += 1;
      if (!$atributo->validar($valor)) {
        Gaiman->logger->trace("No se valido el valor $valor para $key");
        next;
      }
      $self->estructura->{$key} = $valor;
      $puntos--;
    }
  }

  sub preparar_atributo {
    my $self = shift;
  	my $key = shift;
    my $atributo = Universo->actual->atributo_tipo($key);
    my $valor;
    if ($self->personaje->$key) {
      if ($self->personaje->$key ne 'NONAME') {
        $valor = $self->personaje->$key;
      }
    }
    if (exists $self->argumentos->{$key}){
      $valor = $self->argumentos->{$key};
      if(!$atributo->validar($valor)) {
        my $warn = "No es valido el valor $valor para el atributo $key";
        Gaiman->logger->warn($warn);
        warn $warn;
        $valor = undef;
      }
    }
    if (!$valor) {
      $valor = $atributo->alguno($self->estructura);
    }
  	$self->estructura->{$key} = $valor if defined $valor;
  }

  sub asignar {
    my $self = shift;
    foreach my $key (sort keys %{$self->estructura}) {
      my $valor = $self->estructura->{$key};
      $self->personaje->$key($valor) if $valor ne $self->personaje->$key;   
    }
    Gaiman->logger->info('Se construyo ', $self->personaje->name, ': ', $self->personaje->json);
  }
1;