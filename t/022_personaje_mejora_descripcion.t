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
	#Entonces el personaje tendra datos de description body
	like $personaje->size, qr/^(XS|S|M|L|XL)$/, 'tiene size';
	like $personaje->height, qr/\d.\d\d/, 'tiene altura';
	like $personaje->weight, qr/\d\d/, 'tiene peso';
	like $personaje->bust, qr/\d\d/, 'tiene busto';
	like $personaje->waist, qr/\d\d/, 'tiene cintura';
	like $personaje->hip, qr/\d\d/, 'tiene cadera';
}
