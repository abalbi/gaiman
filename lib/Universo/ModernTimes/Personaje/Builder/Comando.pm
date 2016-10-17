package ModernTimes::Personaje::Builder::Comando;
use Data::Dumper;
our $logger = Log::Log4perl->get_logger(__PACKAGE__);

use fields qw(_key _puntos _builder _stash _hecho);
  sub new {
    my $self = shift;
    $self = fields::new($self);
    $self->{_key} = shift;
    $self->{_puntos} = shift;
    return $self;
  }

  sub builder {
    my $self = shift;
    my $valor = shift;
    $self->{_builder} = $valor if defined $valor;
    return $self->{_builder};
  }

  sub stash {
    my $self = shift;
    my $valor = shift;
    $self->{_stash} = $valor if defined $valor;
    $self->{_stash} = undef if $valor eq '__VACIAR__';    
    return $self->{_stash};
  }

  sub hecho {
    my $self = shift;
    my $valor = shift;
    $self->{_hecho} = $valor if defined $valor;
    return $self->{_hecho};
  }


  sub key {
    my $self = shift;
    return $self->{_key};
  }


  sub puntos {
    my $self = shift;
    return $self->{_puntos};
  }

  sub estructura {
    my $self = shift;
    return $self->builder->estructura;
  }

  sub argumentos {
    my $self = shift;
    return $self->builder->argumentos;
  }

  sub personaje {
    my $self = shift;
    return $self->builder->personaje;
  }

  sub hacer {
    my $self = shift;
    $logger->info("Argumentos:",Gaiman->l($self->argumentos));
    return $self->_hacer;    
  }

  sub deshacer {
    my $self = shift;
    my $key = $self->key;
    my $valor = $self->puntos;
    foreach my $nombre (sort keys %{$self->stash}) {
      $self->estructura->$nombre($self->stash->{$nombre});
    }
    $self->hecho(0);
    $self->stash('__VACIAR__');
    return;
  }

1;

package ModernTimes::Personaje::Builder::Comando::Categoria;
use Data::Dumper;
use base qw(ModernTimes::Personaje::Builder::Comando);
our $logger = Log::Log4perl->get_logger(__PACKAGE__);

  sub _hacer {
    my $self = shift;
    my $categoria = $self->key;
    my $valores = [@{$self->puntos}];
    $logger->info('[CATEGORIA] ',$categoria);
    my $subcategorias = Universo->actual->subcategorias($categoria);
    my $casos = [];
    my $hash = {};
    $self->stash($self->estructura->valores($categoria));
    if(Universo->actual->distribuye_puntos($categoria)) {
      #TABLA
      foreach my $valor (@$valores) {
        foreach my $subcategoria (@$subcategorias) {
          my $libres = $self->estructura->sum_libres($subcategoria);
          my $preasignados = $self->estructura->sum_preasignados($subcategoria);
          if(!scalar grep {$_ >= $preasignados} @$valores) {
            $logger->logdie("Falla: Para ", $subcategoria, " se estan preasignados ", $preasignados, ", que es mas que el maximo de los valores a repartir");
          }
          my $factibilidad = $valor - $preasignados;
          my $prioridad = $factibilidad + $libres;
          push @$casos, {
            subcategoria => $subcategoria,
            puntos => $valor,
            libres => $libres,
            preasignados => $preasignados,
            factibilidad => $factibilidad,
            prioridad => $prioridad,
          }
        }
      }

      #FILTROS
      $casos = [sort {$a->{prioridad} <=> $b->{prioridad}} @$casos];
      my $primero = 0;
      my $ultimo = -1 + scalar @$casos;
      foreach my $i ($primero..$ultimo) {
        my $caso = $casos->[$i];
        my $valor = $caso->{puntos};
        my $subcategoria = $caso->{subcategoria};
        $logger->debug('CASO:',Gaiman->l($caso));
        if($caso->{factibilidad} < 0 ){
          $logger->trace('Se ignora ',$subcategoria,' con puntos ', $valor, ' porque tiene factibilidad ', $caso->{factibilidad});
          next;
        }
        if (!$hash->{$valor}) {
          if(scalar grep {$hash->{$_}->{$subcategoria}} grep { $_ != $valor} sort keys %$hash) {
            $logger->trace('Se ignora ',$subcategoria,' con puntos ', $valor, ' porque la categoria ya esta asignada');
            next;
          }
          if(!$caso->{libres} && $caso->{preasignados} < $caso->{puntos}) {
            $logger->logdie('Falla: ',$subcategoria,' no tiene puntos libres, pero sus preasignados(',$caso->{preasignados},') menor a los puntos asignados(',$valor,'). SUGERENCIA: Comprobar si 2 o mas subcategorias tiene preasignados que solo permitirian el uso de un valor a distribuir. Otra posibilidad es que la subcategoria ', $subcategoria, ' tenga preasignados todos sus atributos pero no lleguen a completar el valor minimo definido');
          }
          $logger->trace('Se asigna a ',$subcategoria,' con puntos ', $valor);
          $hash->{$valor}->{$subcategoria} = $caso;
        } else {
          $logger->trace('Se ignora ',$subcategoria,' con puntos ', $valor, ' porque el valor ya esta asignado');
        }
      }
      if(scalar keys %$hash != scalar @$valores) {
        my $diagn = {map {$_, {preasignados => $self->estructura->sum_preasignados($_)}} @$subcategorias};
        $logger->logdie("Fallo: No se pudieron asignar todas las subcategorias. Estas son las preasinaciones: ",Gaiman->l($diagn));
      }
      $logger->debug('HASH:',Gaiman->l($hash));

      # RANDOM
      foreach my $puntos (sort keys %$hash) {
        my $subcategorias = [sort keys %{$hash->{$puntos}}];
        my $subcategoria = $subcategorias->[int rand scalar @$subcategorias];
        $self->asignar_puntos_a_subcat($hash, $puntos, $subcategoria);
      }

      # COMANDOS
      foreach my $puntos (sort keys %$hash) {
        my $subcategoria = [sort keys $hash->{$puntos}]->[0];
        $self->builder->comando_carga($subcategoria, $puntos);
        $self->builder->comando_ultimo->hacer;
      }
    } else {
      foreach my $subcategoria (sort @$subcategorias) {
        $self->builder->comando_carga($subcategoria, $puntos);
        $self->builder->comando_ultimo->hacer;
      }
    }
    $self->hecho(1);
  }

  sub asignar_puntos_a_subcat {
    my $self = shift;
    my $hash = shift;
    my $puntos = shift;
    my $subcategoria = shift;
    foreach my $valor (sort keys %$hash) {
      my $subcategorias = $hash->{$valor};
      my $nombres = [grep {$_ ne $subcategoria} sort keys %$subcategorias];
      foreach my $subcat (@$nombres) {
        delete $hash->{$puntos}->{$subcat};
      }
      foreach my $valor2 (sort keys %$hash) {
        next if $puntos eq $valor2;
        delete $hash->{$valor2}->{$subcategoria};          
      }
    }
  }

1;

package ModernTimes::Personaje::Builder::Comando::Subcategoria;
use base qw(ModernTimes::Personaje::Builder::Comando);
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
use Data::Dumper;

sub _hacer {
  my $self = shift;
  my $subcategoria = $self->key;
  my $puntos = $self->puntos;
  my $atributos = $self->estructura->atributo_tipo($subcategoria);
  my $valores = $self->estructura->valores($subcategoria);
  $logger->info("Hacer subcategoria: ", Gaiman->l($subcategoria)," puntos:", Gaiman->l($puntos));
  if(Universo->actual->distribuye_puntos($subcategoria)) {
    $self->stash($self->estructura->valores($subcategoria));
    $logger->logdie("Para $subcategoria es necesario definir los puntos a distribuir en la subcategoria") if not defined $puntos;
    my $libres = $self->estructura->sum_libres($subcategoria);
    my $preasignados = $self->estructura->sum_preasignados($subcategoria);
    my $disponibles = $puntos - $preasignados;
    $logger->trace("Subcategoria: ",$subcategoria," libres: ", $libres);
    if($preasignados > $puntos) {
      $logger->logdie("Para $subcategoria los puntos asignados($puntos) son menores a los puntos preasignados($preasignados).");
    }
    if(!$libres) {
      if($puntos != $preasignados) {
        $logger->logdie("Para $subcategoria no hay libres($libres) y los puntos asignados($puntos) distintos a los puntos preasignados($preasignados).");
      }
    } else {
      if($libres < $disponibles) {
        $logger->logdie("Para $subcategoria hay libres($libres), pero los disponibles($disponibles) son menos que los libres($libres)");
      }
    }
    my $count = $puntos;
    my $c;
    foreach my $atributo (@$atributos) {
      my $nombre = $atributo->nombre;
      if ($self->estructura->es_previo($nombre)) {
        $logger->trace($nombre, ' esta preasignados :'.Gaiman->l($valores->{$nombre})) ;
        $valores->{$nombre} = $valores->{$nombre}->[int rand scalar @{$valores->{$nombre}}] if ref $valores->{$nombre} eq 'ARRAY';
        $count = $count - $valores->{$nombre} + $atributo->defecto;
      } else {
        $valores->{$nombre} = $atributo->defecto if not defined $val;
        if($valores->{$nombre} < $atributo->validos->[0]) {
          $valores->{$nombre} = $atributo->validos->[0];
          $count = $count - $valores->{$nombre} + $atributo->defecto;
        }
      }
    }
    $logger->logdie("Count es menor a 0 antes de empezar el loop. Preasignados: ", $preasignados," Puntos: ", $puntos) if $count < 0;
    while($count) {
      $c++;
      die "Recusion infinita" if $c == 15;
      my $atributo = $atributos->[int rand scalar @$atributos];
      my $nombre = $atributo->nombre;
      next if $self->estructura->es_previo($nombre);
      my $val = $valores->{$nombre};
      my $new = $val + 1;
      $logger->trace($nombre, " Count: ",Gaiman->l($count), " Valor: ",Gaiman->l($val), " Nuevo: ", Gaiman->l($new));
      if($atributo->validar($new)) {
        $logger->trace(Gaiman->l($new),' es valido para ', $nombre, '. validos: ', Gaiman->l($atributo->validos));
        $valores->{$nombre} = $new;
        $count--;
      } else {
        $logger->trace(Gaiman->l($new),' no es valido para ', $nombre, '. validos: ', Gaiman->l($atributo->validos))
      }
    }
  }
  foreach my $atributo (@{$atributos}) {
    my $nombre = $atributo->nombre;
    $valores->{$nombre} = $valores->{$nombre}->[int rand scalar @{$valores->{$nombre}}] if ref $valores->{$nombre} eq 'ARRAY';
    $self->builder->comando_carga($nombre, $valores->{$nombre});
    $self->builder->comando_ultimo->hacer;
  }
  $self->hecho(1);
}


1;

package ModernTimes::Personaje::Builder::Comando::Atributo;
use base qw(ModernTimes::Personaje::Builder::Comando);
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
use Data::Dumper;

  sub puntos {
    my $self = shift;
    my $key = $self->key;
    $self->{_puntos} = $self->personaje->$key if defined $self->personaje->$key;
    $self->{_puntos} = $self->argumentos->{$key} if defined $self->argumentos->{$key};
    return $self->{_puntos};
  }

  sub _hacer {
    my $self = shift;
    my $key = $self->key;
    my $valor = $self->puntos;
    my $atributo = $self->estructura->atributo_tipo($key);
    $self->stash({$key => $self->estructura->$key});
    $valor = $valor->[int rand scalar @$valor] if ref $valor eq 'ARRAY';
    if(!$atributo->es_vacio($valor)) {
      $logger->logdie("No se valido $valor para el atributo $key ".Gaiman->l($atributo->validos)) if !$atributo->validar($valor);
    } else {
      $logger->trace("Valor vacio: ", Gaiman->l($valor), " previo: ", $self->estructura->es_previo($key), " vacio: ", $atributo->es_vacio($self->estructura->$key));
      $valor = $self->estructura->$key($atributo->alguno($self)) if !$self->estructura->es_previo($key) || $atributo->es_vacio($self->estructura->$key);
    }
    $self->estructura->$key($valor);
    $logger->info('[COMANDO] se asigna ', Gaiman->l($valor), ' a ', Gaiman->l($key));
    if($atributo->alteraciones->{$valor}) {
      $logger->info('[COMANDO] aplican alteraciones a ', Gaiman->l([keys %{$atributo->alteraciones->{$valor}}]), ' para ', Gaiman->l($key));
      foreach my $key2 (keys %{$atributo->alteraciones->{$valor}}) {
        my $atributo2 = $self->estructura->atributo_tipo($key2);
        $atributo2->validos($atributo->alteraciones->{$valor}->{$key2})
      }
    }
    $self->hecho(1);
    return;
  }
1;