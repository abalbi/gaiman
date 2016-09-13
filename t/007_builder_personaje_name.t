use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;

#Dado que uso Gaiman
use Gaiman;
#Y tengo una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;

{
	#Cuando le hago build en un nuevo personaje
	my $personaje = Personaje->new;
	my $builder = Universo->actual->builder_personaje;
	$builder->personaje($personaje);
	$builder->build;
	#Entonces el personaje tendra un name
  isnt($personaje->name, 'NONAME','el personaje tiene name distinto de NONAME');	
}

{
  #Cuando le hago build en un personaje que ya tenie name
  my $personaje = Personaje->new;
  $personaje->name('Ivana');
  my $builder = Universo->actual->builder_personaje;
  $builder->personaje($personaje);
  $builder->build;
  #Entonces el personaje tendra el mismo name
  is($personaje->name, 'Ivana','el personaje tendra el mismo name');  
}

{
  #Cuando le hago build con el argumento name a un nuevo personaje
  my $personaje = Personaje->new;
  my $builder = Universo->actual->builder_personaje;
  $builder->personaje($personaje);
  $builder->build({name => 'Ivana'});
  #Entonces el personaje tendra el name definido en el argumento
  is($personaje->name, 'Ivana','el personaje tendra el name definido en el argumento');  
}


