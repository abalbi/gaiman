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
			'Mide', $self->height
		)
	);
	return $str;
}

sub t {
	my $self = shift;
	my $str = shift;
	return Gaiman->t($self, $str);
	
}
1;
