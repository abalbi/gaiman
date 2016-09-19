use strict;
use Term::ANSIColor qw(colorstrip);
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Data::Dumper;

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
{
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra en el detalle descripcion
	like $personaje->detalle, 
#		qr/[\w|ñ]+ es \w+ de pelo \w+ y \w+. Sus ojos son \w+. Tiene \d\d años. Mide \d.\d\d, pesa \d\d kg y sus medidas son \d\d\d*-\d\d\d*-\d\d\d*./,
		qr/[\w|ñ]+ es [\w|ñ]+ de pelo \w+ y \w+. Sus ojos son \w+. Tiene \d\d años. Mide \d.\d\d, pesa \d\d kg y sus medidas son \d\d\d*-\d\d\d*-\d\d\d*./,
		'el personaje tendra en el detalle descripcion';
}
