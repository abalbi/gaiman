use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado uso el modulo Gaiman
use Gaiman;
#Cuando ModernTimes es instanciado
ModernTimes->new;
#Entonces ModernTimes debe tener el atributo tipo sex
is(Universo->actual->atributo_tipo(q(sex))->nombre, 'sex', 'ModernTimes debe tener el atributo tipo sex');
