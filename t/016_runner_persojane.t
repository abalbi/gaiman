use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Data::Dumper;

#Dado el uso de Gaiman
use Gaiman;

#Cuando ejecuto runner en Gaiman sin parametros
my $str = Gaiman->runner;
#Entonces no recibo ningun output
is $str, '', 'no recibo ningun output';

#Cuando ejecuto runner en Gaiman con el parametro personaje
my $str = Gaiman->runner(comando => 'personaje');
#Entonces no recibo ningun output
isnt $str, '', 'recibo la description de un personaje';

#Cuando ejecuto runner en Gaiman con el parametro personaje sin log
my $str = Gaiman->runner(comando => 'personaje', appearance => 5, sex => 'f', log => 'OFF');
#Entonces no recibo ningun output
isnt $str, '', 'recibo la description de un personaje';

#Cuando ejecuto runner en Gaiman con el parametro personaje pero con atributes
my $str = Gaiman->runner(comando => 'personaje', appearance => 5, size => 'M', sex => 'f');
#Entonces no recibo ningun output
isnt $str, '', 'recibo la description de un personaje';

#Cuando ejecuto runner en Gaiman con el parametro personaje y random
my $str = Gaiman->runner(comando => 'personaje', random => 'random');
#Entonces no recibo ningun output
isnt $str, '', 'recibo la description de un personaje';