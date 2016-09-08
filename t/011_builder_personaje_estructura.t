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
my $builder = ModernTimes::Builder::Personaje->new;

{
#Cuando creo un personaje
#Entonces debe obtener siempre la misma esctructura
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	my $builder = ModernTimes::Builder::Personaje->new;
	$builder->personaje($personaje);

    $builder->estructura({});
    $builder->preparar('sex');
    is $builder->estructura->{sex}, 'f';

    $builder->preparar('name');
    is $builder->estructura->{name}, 'Lara';

    $builder->preparar('virtues', 10);
    is $builder->estructura->{conviction}, 4;
    is $builder->estructura->{instinct}, 2;
    is $builder->estructura->{courage}, 4;

    $builder->preparar('attribute', [10,8,6]);
    is $builder->estructura->{strengh}, 3;
    is $builder->estructura->{dexterity}, 1;
    is $builder->estructura->{stamina}, 2;


    $builder->preparar('description');


}