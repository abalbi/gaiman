use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

$ModernTimes::Personaje::Builder::logger->level('INFO');
$ModernTimes::Personaje::Builder::Estructura::logger->level('INFO');

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
	#Entonces el personaje tendra attributes
	ok($personaje->strengh, 'tiene strengh');
	ok($personaje->dexterity, 'tiene dexterity');
	ok($personaje->stamina, 'tiene stamina');
	ok($personaje->charisma, 'tiene charisma');
	ok($personaje->manipulation, 'tiene manipulation');
	ok($personaje->appearance, 'tiene appearance');
	ok($personaje->perception, 'tiene perception');
	ok($personaje->intelligence, 'tiene intelligence');
	ok($personaje->wits, 'tiene wits');
}
{
	#Cuando le hago build en un personaje con appearance 5
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra attributes
	is($personaje->appearance, 5, 'tiene appearance 5');
	ok($personaje->strengh, 'tiene strengh');
	ok($personaje->dexterity, 'tiene dexterity');
	ok($personaje->stamina, 'tiene stamina');
	ok($personaje->charisma, 'tiene charisma');
	ok($personaje->manipulation, 'tiene manipulation');
	ok($personaje->appearance, 'tiene appearance');
	ok($personaje->perception, 'tiene perception');
	ok($personaje->intelligence, 'tiene intelligence');
	ok($personaje->wits, 'tiene wits');
}

{
	#Cuando le hago build en un personaje con appearance 5 y charisma 5
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	$personaje->charisma(5);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	#Entonces se disparar un error por que excede el maximo asignable
	dies_ok {
		$builder->build;
	} 'se disparar un error por que excede el maximo asignable';
	like $@, qr/\[SUBCATEROGIA\] \w+: menos puntos \(\d+\) que preseteados \(\d+\)/, 'con un mensaje correspondiente';
}

{
	#Cuando le hago build en un personaje con wits 5, perception 4, appearance 5 y charisma 4
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	$personaje->charisma(4);
	$personaje->wits(5);
	$personaje->perception(4);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	#Entonces se disparar un error por que dos categorias tiene una sola opcion posible
	dies_ok {
		$builder->build;
	} 'se disparar un error por que dos categorias tiene una sola opcion posible';
	like $@, qr/\[SUBCATEROGIA\] \w+: menos puntos \(\d+\) que preseteados \(\d+\)/, 'con un mensaje correspondiente';
}

{
	#Cuando le hago build en un personaje con wits 5, perception 2, appearance 5,  charisma 4, dexterity 2 y stamina 5
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	$personaje->charisma(4);
	$personaje->wits(5);
	$personaje->perception(2);
	$personaje->stamina(5);
	$personaje->dexterity(2);
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	#Entonces se disparar un error por que se trata de asignar 2 veces el mismo valor a dos subcategorias distintas
	dies_ok {
		$builder->build;
	} 'Se trata de asignar 2 veces el mismo valor a dos subcategorias distintas. Inaudito';
	like $@, qr/\[SUBCATEROGIA\] \w+: menos puntos \(\d+\) que preseteados \(\d+\)/, 'con un mensaje correspondiente';
}
