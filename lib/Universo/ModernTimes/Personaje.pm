package ModernTimes::Personaje;
use Term::ANSIColor;
use strict;
use base 'Personaje';
use Data::Dumper;

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self = $self->SUPER::new($args);
	return $self;
}

sub description_texto {
	my $self = shift;
	my $str = Gaiman->parrafo(
		Gaiman->oracion($self, 
			$self->name,
			'es', $self->heir_color,
			'de pelo', $self->heir_long,
			'y', $self->heir_form,
		),
		Gaiman->oracion($self, 
			'Sus ojos son', $self->eyes_color,
		),
		Gaiman->oracion($self, 
			'Tiene', $self->age, 'años'
		),
		Gaiman->oracion($self,
			'Mide', $self->body->{height},
			', pesa', $self->body->{weight}, 'kg',
			' y sus medidas son', $self->body->{bust}.'-'.$self->body->{waist}.'-'.$self->body->{hip},
		)
	);
	return $str;
}

sub t {
	my $self = shift;
	my $str = shift;
	return Gaiman->t($self, $str);
	
}

sub detalle {
	my $self = shift; 
	my $str = '';
  my $parrafos = [];
  push @$parrafos, colored $self->name, 'UNDERLINE BOLD';  
  push @$parrafos, $self->concept;  
  $self->detalle_categoria($parrafos, 'attribute');
  $self->detalle_categoria($parrafos, 'ability');
  $self->detalle_categoria($parrafos, 'advantage');
  push @$parrafos, $self->description_texto;
  push @$parrafos, colored('edad: ', 'BOLD').$self->age;
  push @$parrafos, colored("cuerpo:\n", 'BOLD') . $self->body_detalle;
	push @$parrafos, colored("biografia:", 'BOLD');
  push @$parrafos, $self->detalle_biografia;
  $str = Gaiman->parrafos(@$parrafos);
  return $str;
}

sub detalle_biografia {
	my $self = shift; 
  my $parrafos = [];
  foreach my $evento (@{$self->eventos}) {
  	push @$parrafos, $evento->description;
  }
  return @$parrafos;
}

sub detalle_categoria {
  my $self = shift;
  my $parrafos = shift;
  my $tag = shift;
  my $hash = {};
  my $atributos = Universo->actual->atributo_tipo($tag);
  push @$parrafos, colored($tag, 'BOLD');
  foreach my $atributo (@{$atributos}) {
    my $nombre = $atributo->nombre;
    $hash->{$atributo->subcategoria} = [] if !$hash->{$atributo->subcategoria};
    my $value = sprintf("%s: %s", $nombre, $self->$nombre);
    $value = colored($value, 'ITALIC BOLD') if $self->$nombre >= 4;
    push @{$hash->{$atributo->subcategoria}}, $value;
  }
  foreach my $atributo (@{$atributos}) {
    $hash->{$atributo->subcategoria} = join('; ',@{$hash->{$atributo->subcategoria}}) if ref $hash->{$atributo->subcategoria} eq 'ARRAY';
  }
  foreach my $atributo (@{$atributos}) {
    if ($hash->{$atributo->subcategoria}) {
      push @$parrafos, colored($atributo->subcategoria, 'BOLD') . ": " . $hash->{$atributo->subcategoria}; 
      $hash->{$atributo->subcategoria} = undef;
    }
  }
}
1;
