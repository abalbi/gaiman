use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#$Personaje::logger->level('TRACE');
#$ModernTimes::Atributo::Tipo::logger->level('INFO');
#$ModernTimes::Personaje::Builder::logger->level('TRACE');
#$ModernTimes::Personaje::Builder::Estructura::logger->level('INFO');


#Dado que uso Gaiman
use Gaiman;
#Y tengo una instancia de ModernTimes
ModernTimes->new;
#Y tengo un personaje
my $personaje = Personaje->new;
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje

my $builder = Universo->actual->builder_personaje;
$builder->personaje($personaje);
$builder->build;
#Entonces el personaje tiene sex
ok($personaje->sex, 'el personaje tiene sex');
#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje definiendo un sex
$personaje = Personaje->new;
my $builder = Universo->actual->builder_personaje;
$builder->personaje($personaje);
$builder->build({sex => 'f'});
#Entonces el personaje tiene sex f
is($personaje->sex,'f', 'el personaje tiene sex f');

#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje definiendo un sex invalido
$personaje = Personaje->new;
my $builder = Universo->actual->builder_personaje;
$builder->personaje($personaje);
throws_ok {
	$builder->build({sex => 'INVALID'});
} qr/No se valido \w+ para el atributo sex \'\[.+\]\'/;
#Entonces el personaje tiene sex f
isnt($personaje->sex,'INVALID', 'el personaje NO tiene sex INVALID');
exit;


#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje con sex definido
$personaje = Personaje->new;
$personaje->sex('f');
my $builder = Universo->actual->builder_personaje;
$builder->personaje($personaje);
$builder->build;
#Entonces el personaje tiene sex f
is($personaje->sex,'f', 'el personaje tiene sex f');
