use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado el uso de Gaiman
use Gaiman;
ModernTimes->new;
#Cuando pido el entorno actual
my $entorno = Entorno->actual;
#Entonces debo recibir una instancia de Entorno
isa_ok($entorno, 'Entorno');

#Cuando agrego un personaje al entorno actual
#Y no existe un personaje con ese nombre en el entorno
my $personaje = Personaje->new();
$personaje->name('Ivana');
my $boo = Entorno->agregar($personaje);
#Entonces debo recibir un true
ok $boo, 'debo recibir un true';

#Cuando agrego un personaje al entorno actual
#Y existe un personaje con ese nombre en el entorno
$boo = Entorno->agregar($personaje);
#Entonces debo recibir un false
ok !$boo, 'debo recibir un false';

#Y debo obtener un warn de que no se dio de alta al personaje en el entorno

#Cuando busque el personaje por nombre
my $per = Entorno->buscar('Ivana');
#Entonces debo recibir un personaje con ese nombre
is($per->name, 'Ivana', 'debo recibir un personaje con ese nombre');