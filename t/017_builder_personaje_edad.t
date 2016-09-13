use strict;
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
	$builder->build({sex => 'f'});
	#Y en eventos del personaje tendre un evento
	my $evento = $personaje->eventos->[0];
	isa_ok($evento, 'Evento');
	is $evento->nombre, 'NACER', 'tiene el nombre correcto';
	is $evento->tipo->nombre, 'NACER', 'es del tipo que corresponde';
	is $evento->sujeto, $personaje, 'tiene sujeto';
	like $evento->description, qr/ nace el \d\d de \w\w\w de \d\d\d\d a las \d\d:\d\d/, 'tiene descripcion';
}

