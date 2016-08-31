use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado usa Gaiman
use Gaiman;
#Y ModernTimes es instanciado
ModernTimes->new;
#Y un Personaje
my $personaje = Personaje->new();
#Y que el personaje tenga sex 'f'
$personaje->sex('f');
#Cuando ejecuto el metodo sex
my $sex = $personaje->sex;
#Entonces debo obtener el valor 'f'
is($sex, 'f', 'debo obtener el valor f');

#Cuando ejecuto el metodo sex_tipo
my $tipo = $personaje->sex_tipo;
#Entonces debo obtener el ModernTimes::Atributo::Tipo con nombre 'sex'
isa_ok($tipo, 'ModernTimes::Atributo::Tipo');