package ModernTimes::Personaje;

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
			'Mide', $self->height,
			', pesa', $self->weight, 'kg',
			' y sus medidas son', $self->bust.'-'.$self->waist.'-'.$self->hip,
		)
	);
	return $str;
}

sub t {
	my $self = shift;
	my $str = shift;
	return Gaiman->t($self, $str);
	
}

sub age {
	my $self = shift;
	my $date_birth = DateTime->from_epoch(epoch => $self->date_birth);
	return Universo->actual->base_date->year - $date_birth->year;	
}
1;
