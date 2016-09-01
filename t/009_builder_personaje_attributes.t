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
	#Cuando le hago build en un nuevo personaje
	my $personaje = Personaje->new;
	my $builder = ModernTimes::Builder::Personaje->new;
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
	my $builder = ModernTimes::Builder::Personaje->new;
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
	#Cuando le hago build en un personaje con appearance 5
	my $personaje = Personaje->new;
	$personaje->appearance(5);
	$personaje->charisma(5);
	my $builder = ModernTimes::Builder::Personaje->new;
	$builder->personaje($personaje);
	dies_ok {
		$builder->build;
	}
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