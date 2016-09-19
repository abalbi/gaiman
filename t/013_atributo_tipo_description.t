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
	#Entonces el personaje tendra description
	ok $personaje->description_texto, 'tiene description';
}

{
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;

	$builder->personaje($personaje);
	$builder->build({sex => 'f', appearance => 5, body => {size => 'M'}, heir_color => 'castañ[a|o]', heir_long => 'largo'});
	#Entonces el personaje tendra description
	is $personaje->body->{size}, 'M';
	like $personaje->description_texto, qr/castaña/;
	like $personaje->description_texto, qr/Tiene \d\d años/;
	like $personaje->description_texto, qr/sus medidas son \d\d\d*-\d\d\d*-\d\d\d*/;
	like $personaje->description_texto, qr/Mide \d.\d\d, pesa \d\d kg/;
}
