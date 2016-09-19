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
$builder->build({body => {height => 1.55}});
#Entonces el personaje tiene la altura definida
is $personaje->body->{height}, 1.55, 'el personaje tiene la altura definida';

}