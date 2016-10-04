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

  sub hacer {
    my $self = shift;
    $logger->info('[COMANDO]: ',$self->key, ':' , Gaiman->l($self->puntos));
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
    my $valores = $self->puntos;
    my $subcategorias = Universo->actual->subcategorias($categoria);
    my $hash;
    $self->stash($self->estructura->valores($categoria));
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
      $self->builder->comando_carga($subcategoria,$hash->{$subcategoria}->{posibles}->[0]);
      $self->builder->comando_ultimo->hacer;

    }
    $self->hecho(1);
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
  my $atributos = Universo->actual->atributo_tipo($subcategoria);
  $self->stash($self->estructura->valores($subcategoria));
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
        $self->builder->comando_carga($nombre,$new);
        $self->builder->comando_ultimo->hacer;
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
      $self->builder->comando_carga($nombre,$new);
      $self->builder->comando_ultimo->hacer;
    }
  }
  $self->hecho(1);
}



1;

package ModernTimes::Personaje::Builder::Comando::Atributo;
use base qw(ModernTimes::Personaje::Builder::Comando);
our $logger = Log::Log4perl->get_logger(__PACKAGE__);
use Data::Dumper;

sub _hacer {
  my $self = shift;
  my $key = $self->key;
  my $valor = $self->puntos;
  my $atributo = Universo->actual->atributo_tipo($key);
  $self->stash({$key => $self->estructura->$key});
  if(defined $valor) {
    $self->estructura->$key($valor);
  } else {
    $self->estructura->$key($atributo->alguno($self)) if !$self->estructura->es_previo($key) || $atributo->es_vacio($self->estructura->$key);
  }
  $self->hecho(1);
  return;
}

1;