use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado que uso Gaiman
use Gaiman;
#Y tengo una instancia de ModernTimes
ModernTimes->new;
#Y tengo un personaje
my $personaje = Personaje->new;
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje

my $builder = ModernTimes::Builder::Personaje->new;
$builder->personaje($personaje);
$builder->build;
#Entonces el personaje tiene sex
ok($personaje->sex, 'el personaje tiene sex');

#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje definiendo un sex
$personaje = Personaje->new;
my $builder = ModernTimes::Builder::Personaje->new;
$builder->personaje($personaje);
$builder->build({sex => 'f'});
#Entonces el personaje tiene sex f
is($personaje->sex,'f', 'el personaje tiene sex f');

#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje definiendo un sex invalido
$personaje = Personaje->new;
my $builder = ModernTimes::Builder::Personaje->new;
$builder->personaje($personaje);
$builder->build({sex => 'INVALID'});
#Entonces el personaje tiene sex f
isnt($personaje->sex,'INVALID', 'el personaje NO tiene sex INVALID');


#################################################
#Cuando ejecuto build en un ModernTimes::Builder::Personaje en el personaje con sex definido
$personaje = Personaje->new;
$personaje->sex('f');
my $builder = ModernTimes::Builder::Personaje->new;
$builder->personaje($personaje);
$builder->build;
#Entonces el personaje tiene sex f
is($personaje->sex,'f', 'el personaje tiene sex f');

