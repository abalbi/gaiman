use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado uso el modulo Gaiman
use Gaiman;
#Cuando ModernTimes es instanciado
ModernTimes->new;
#Entonces ModernTimes va a ser el actual
isa_ok(Universo->actual, 'ModernTimes');
#Y ModernTimes debe ser un Universo
isa_ok(Universo->actual, 'Universo');
