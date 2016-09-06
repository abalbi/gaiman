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
	#Cuando le hago build en un nuevo personaje y defino atributos en el build
	my $personaje = Personaje->new;
	my $builder = ModernTimes::Builder::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({stamina => [3..4], instinct => [1..3], heir_color => [qw(castañ[a|o] moroch[a|o])]});
	#Entonces el personaje tendra atributos dentro de los rangos definidos
	ok scalar grep({$_ == $personaje->stamina  }   qw(3..4)), 'tiene valor definido por categoria';
	ok scalar grep({$_ == $personaje->instinct }   qw(1..3)), 'tiene valor definido por subcategoria';
	ok scalar grep({$_ == $personaje->heir_color } qw(castañ[a|o] moroch[a|o])), 'tiene valor definido por atributo';
}

