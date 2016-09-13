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
    $self->preparar('date_birth');
    $self->preparar('name');
    $self->preparar('virtues', 10);
    $self->preparar('attribute', [10,8,6]);
    $self->preparar('ability', [13,9,5]);
    $self->preparar('description');
    $self->asignar;
    $self->crear_eventos;
    return $self;  	
  }

  sub crear_eventos {
    my $self = shift;
    my $atributos = Universo->actual->atributo_tipos;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      if($self->personaje->$key) {
        my $eventos = $atributo->crear_eventos($self->personaje);
        push @{$self->personaje->eventos}, @{$eventos} if defined $eventos;
        Gaiman->logger->trace('crear_eventos: ', $key);
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
    $self->estructura->{hash} = {};
    my $atributos = Universo->actual->atributo_tipo($key);
    $atributos = [$atributos] if ref $atributos ne 'ARRAY';
    my $temp = [@{$valores}] if $valores;
    $self->preparar_categoria_min_max($atributos);
    $self->preparar_categoria_reducir_rangos($valores);
    $self->preparar_categoria_asignacion( $temp);
    foreach my $key (sort keys %{$self->estructura->{hash}}) {
      $self->preparar_subcategoria($key, $self->estructura->{hash}->{$key}->{asignado});
    }
  }


  sub preparar_categoria_min_max {
    my $self = shift;
    my $atributos = shift;
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      $self->estructura->{hash}->{$atributo->subcategoria} = {
        min => 0,
        max => 0,
        subcategoria => $atributo->subcategoria
      } if !$self->estructura->{hash}->{$atributo->subcategoria};
      if ($self->personaje->$key) {
        $self->estructura->{hash}->{$atributo->subcategoria}->{min} += $self->personaje->$key;
        $self->estructura->{hash}->{$atributo->subcategoria}->{max} += $self->personaje->$key;
      } else {
        if ($self->argumentos->{$key}) {
          $self->argumentos->{$key} = $self->argumentos->{$key}->[int rand scalar @{$self->argumentos->{$key}}] if ref $self->argumentos->{$key} eq 'ARRAY';
          $self->estructura->{hash}->{$atributo->subcategoria}->{min} += $self->argumentos->{$key};
          $self->estructura->{hash}->{$atributo->subcategoria}->{max} += $self->argumentos->{$key}; 
        } else {
          if($atributo->validos) {
            $self->estructura->{hash}->{$atributo->subcategoria}->{min} += $atributo->validos->[0];
            $self->estructura->{hash}->{$atributo->subcategoria}->{max} += $atributo->validos->[$#{$atributo->validos}]; 
          }
        }
      }
    }
    Gaiman->logger->trace('preparar_categoria: MINIMOS: '.encode_json($self->estructura->{hash}));
  }

  sub preparar_categoria_asignacion {
    my $self = shift;
    my $temp = shift;
    if($temp) {
      my $ordenados = [sort {$b->{min} <=> $a->{min}} values %{$self->estructura->{hash}}];
      my $ordenados = [sort {$b->{subcategoria} cmp $a->{subcategoria}} values %{$self->estructura->{hash}}];
      foreach my $subcategoria (@$ordenados) { 
        my $asignado = $subcategoria->{rango}->[int rand scalar @{$subcategoria->{rango}}];
        $subcategoria->{asignado} = $asignado;
        $subcategoria->{rango} = [];
        foreach my $subcat (sort {$a->{key} cmp $b->{key}} values %{$self->estructura->{hash}}) {
          next if $subcat->{asignado};
          $subcat->{rango} = [grep {$_ ne $subcategoria->{asignado}} @{$subcat->{rango}}];
        }
      }
    }
    Gaiman->logger->trace('preparar_categoria: ASIGNACION: '.encode_json($self->estructura->{hash}));
  }

  sub preparar_categoria_reducir_rangos {
    my $self = shift;
    my $valores = shift;
    my $rangos_con_un_valor = 0;
    return if !$valores;
    foreach my $key (sort keys %{$self->estructura->{hash}}) {
      my $subcat = $self->estructura->{hash}->{$key};
      my $rango = [@$valores];
      $rango = [grep {$_ < $subcat->{max}} @$rango];
      $rango = [grep {$_ > $subcat->{min} } @$rango];
      $subcat->{rango} = $rango;
    }
    foreach my $key (sort keys %{$self->estructura->{hash}}) {
      my $subcat = $self->estructura->{hash}->{$key};
      my $rango = $subcat->{rango};
      Gaiman->error("La subcategoria $key tiene un minimo de $subcat->{min} y los valores pasados son @$valores ".encode_json($self->estructura->{hash})) if$valores->[0] < $subcat->{min};
      Gaiman->error("Se encontraron una subcategoria sin valores posibles a asignar. Lo mas posible es que sea por que tenemos dos subcategorias declaradas con minimos que requieren el mismo valor: ".encode_json($self->estructura->{hash})) if scalar @$rango == 0;
      if(scalar @$rango == 1) {
        my $unico = $rango->[0];
        foreach my $key2 (sort keys %{$self->estructura->{hash}}) {
          next if $key eq $key2;
          my $subcat2 = $self->estructura->{hash}->{$key2};
          my $rango2 = $subcat2->{rango};
          $rango2 = [grep {$_ != $unico} @$rango2];
          $subcat2->{rango} = $rango2;
        }
      }
      $subcat->{rango} = $rango;
    }

    Gaiman->logger->trace('preparar_categoria: RANGOS: '.encode_json($self->estructura->{hash}));
    Gaiman->error("Se encontraron 2 o mas subcategorias que solo pueden usar un valor. Esto es imposible") if $rangos_con_un_valor > 1;
  }

  sub preparar_subcategoria_filtro {
    my $self = shift;
    my $atributos = shift;
    my $filtrados = [];
    foreach my $atributo (@{$atributos}) {
      my $key = $atributo->nombre;
      $self->estructura->{$key} = $atributo->validos->[0] if $atributo->validos;
      if ($self->personaje->$key || $self->argumentos->{$key}) {
        $self->preparar_atributo($key); 
        push @$filtrados, $key;
      }
    }
    return $filtrados;
  }

  sub preparar_subcategoria {
    my $self = shift;
    my $key = shift;
    my $valor = shift;
    my $atributos = Universo->actual->atributo_tipo($key);
    $atributos = [$atributos] if ref $atributos ne 'ARRAY';
    my $filtrados = $self->preparar_subcategoria_filtro($atributos);
    my $sum = $self->sum($atributos);
    my $puntos = $valor - $sum;
    Gaiman->error("El numero de puntos asignados ($sum) supera a los asignar ($valor)") if $puntos < 0;
    my $c = 20;
    if($puntos) {
      while (1) {
        $c--;
        Gaiman->error("Se corta ciclo por recucion infinita") if !$c;
        last if !$puntos;
        my $atributo = $atributos->[int rand scalar @$atributos];
        my $key = $atributo->nombre;
        if (scalar grep {$_ eq $key} @$filtrados) {
          Gaiman->logger->trace("Se filtra el atributo $key por tener valor previo");
          next;
        }
        my $valor = $self->estructura->{$key};
        $valor += 1;
        if($atributo->validar($valor)) {
          $self->preparar_atributo($atributo->nombre, $valor);
          $puntos--;
        }
      }
    } else {
      foreach my $atributo (@{$atributos}) {
        $self->preparar_atributo($atributo->nombre);   
      }
    }
  }

  sub preparar_atributo {
    my $self = shift;
  	my $key = shift;
    my $valor_parametro = shift;
    my $valor = $valor_parametro;
    my $valor_random;
    my $atributo = Universo->actual->atributo_tipo($key);
    if (exists $self->argumentos->{$key}){
      if(ref $self->argumentos->{$key} eq 'ARRAY') {
        $valor = $self->argumentos->{$key}->[int rand scalar @{$self->argumentos->{$key}}];
      } else {
        $valor = $self->argumentos->{$key};
      }
    }
    if ($self->personaje->$key) {
      if ($self->personaje->$key ne 'NONAME') {
        $valor = $self->personaje->$key;
      }
    }
    if (not defined $valor) {
      $valor_random = $atributo->alguno($self->estructura);
      $valor = $valor_random
    }
    if(!$atributo->validar($valor)) {
      Gaiman->warn("No es valido el valor $valor para el atributo $key");
      $valor = undef;
    }
    Gaiman->logger->trace("preparar_atributo $key: ".encode_json({
      parametro => $valor_parametro,
      argumentos => $self->argumentos->{$key},
      personaje => $self->personaje->$key,
      random => $valor_random,
      final => $valor,
    }));
    $self->estructura->{$key} = $valor if defined $valor;
    return;
  }

  sub asignar {
    my $self = shift;
    foreach my $key (sort keys %{$self->estructura}) {
      next if $key eq 'hash';
      my $valor = $self->estructura->{$key};
      $self->personaje->$key($valor) if $valor ne $self->personaje->$key;   
    }
    Gaiman->logger->info('Se construyo ', $self->personaje->name, ': ', $self->personaje->json);
  }
1;