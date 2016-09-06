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
my $builder = ModernTimes::Builder::Personaje->new;
{
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({sex => 'f'});
	#Entonces el personaje tendra description
	print Dumper $personaje->description_texto;
}

{
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;
	$personaje->heir_color('rubi[a|o]');

	$builder->personaje($personaje);
	$builder->build({sex => 'f', stamina => 1, strengh => 1});
	#Entonces el personaje tendra description
	print Dumper $personaje->description_texto;
}
