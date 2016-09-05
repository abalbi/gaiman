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
	my $personaje = Personaje->new;
	my $builder = ModernTimes::Builder::Personaje->new;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra abilities
	my $abilities = [qw(athletics brawl dodge empathy expression intimidation leadership streetwise subterfuge animal_ken crafts drive etiquette firearms melee performance security stealth survival academics bureaucracy computer finance investigation law linguistics medicine occult politics research science)];
	ok scalar(grep {$personaje->$_ != 0} @$abilities), 'el personaje tendra abilities';
}

