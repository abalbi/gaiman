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
$personaje->heir_color('rubi[a|o]');
$builder->personaje($personaje);
dies_ok {
	$builder->build({sex => 'f', stamina => 1, strengh => 1, manipulation => 1, charisma => 1});
}
}

{
#Y le hago build en un otro nuevo personaje con stamina y strengh en 1
my $personaje = ModernTimes::Personaje->new;
$personaje->heir_color('rubi[a|o]');
$builder->personaje($personaje);
lives_ok {
	$builder->build({sex => 'f', stamina => 1, strengh => 1});
}

}