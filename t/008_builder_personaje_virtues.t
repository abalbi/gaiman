use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
{
	#Cuando le hago build en un nuevo personaje
	my $personaje = Personaje->new;
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra las virtudes conviction, instinct y courage
	ok($personaje->conviction, 'tiene conviction');
	ok($personaje->instinct, 'tiene instinct');
	ok($personaje->courage, 'tiene courage');
}
{
	#Cuando le hago build en un personaje que ya tenie conviction
	my $personaje = Personaje->new;
	$personaje->conviction(3);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra el mismo conviction
	is($personaje->conviction, 3, 'el personaje tendra el mismo conviction');
	#Y el personaje tendra las virtudes instinct y courage
	ok($personaje->instinct, 'tiene instinct');
	ok($personaje->courage, 'tiene courage');
}
{
	#Cuando le hago build con el argumento conviction a un nuevo personaje
	my $personaje = Personaje->new;
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build({conviction => 4});
	#Entonces el personaje tendra el conviction definido en el argumento
	is($personaje->conviction, 4, 'el personaje tendra el conviction definido en el argumento');
	#Y el personaje tendra las virtudes instinct y courage
	ok($personaje->instinct, 'tiene instinct');
	ok($personaje->courage, 'tiene courage');
}
{
	#Cuando le hago build con el argumento conviction a un personaje que tenga instinct
	my $personaje = Personaje->new;
	$personaje->instinct(3);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build({conviction => 4});
	#Entonces el personaje tendra el conviction definido en el argumento
	is($personaje->conviction, 4, 'el personaje tendra el conviction definido en el argumento');
	#Y el personaje tendra el mismo instinct del anterior
	is($personaje->instinct, 3,'tiene instinct del anterior');
	#Y el personaje tendra la virtud courage
	ok($personaje->courage, 'tiene courage');

}

{
	#Cuando le hago build argumentos que superen el maximo de puntos a asignar a la subcategoria
	#Entonces dara un error
	my $personaje = Personaje->new;
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	dies_ok {
		$builder->build({conviction => 5, instinct => 5
	}), 'El numero de puntos asignados (11) supera a los asignar (10)', 'dara un error'}
}