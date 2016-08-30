use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#001_main.t
#Dado uso el modulo Gaiman
use Gaiman;
#Cuando pido una instancia
my $instancia = Gaiman->instancia;
#Entonces tengo una instancia
isa_ok $instancia, 'Gaiman', 'tengo una instancia';

#Cuando pido una instancia
#Y pido otra instancia
my $instancia1 = Gaiman->instancia;
my $instancia2 = Gaiman->instancia;
#Entonces las dos seran la misma instancia
is $instancia1, $instancia2, "las dos seran la misma instancia";