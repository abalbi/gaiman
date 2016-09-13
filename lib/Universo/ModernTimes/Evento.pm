package ModernTimes::Evento;

use strict;
use base 'Evento';
use Data::Dumper;

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self = $self->SUPER::new($args);
	return $self;
}

1;
