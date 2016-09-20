use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder_evento = Universo->actual->builder_evento;
my $builder_personaje = Universo->actual->builder_personaje;

{
	#Cuando el evento esta generado sin personajes
	$builder_evento->build({tipo => 'BESAR'});
	#Entonces se autogeneran personajes
	my $evento = $builder_evento->evento;
	like $evento->description, qr/\w+ besa a \w+/, 'se autogeneran personajes' ;
	#Y el evento esta en la biografia de un personaje y del otro
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besador->eventos}), 1, 'el evento esta en la biografia de un personaje';
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besado->eventos}), 1, 'el evento esta en la biografia del otro';
	#Y el evento esta en el entorno
	is scalar(grep {$_ eq $evento} @{Entorno->actual->eventos}), 1, 'el evento esta en el entorno';
}

{
	#Cuando el evento esta generado con personajes previos
	my $per1 = $builder_personaje->clean->build({sex => 'm'})->personaje;
	my $per2 = $builder_personaje->clean->build({sex => 'f'})->personaje;
	is $per1->sex,'m';
	is $per2->sex,'f';
	my $nombre1 = $per1->name;
	my $nombre2 = $per2->name;
	$builder_evento->build({besador => $per1,besado => $per2, tipo => 'BESAR'});
	#Entonces se autogeneran personajes
	my $evento = $builder_evento->evento;
	like $evento->description, qr/$nombre1 besa a $nombre2/, 'se autogeneran personajes' ;
	#Y el evento esta en la biografia de un personaje y del otro
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besador->eventos}), 1, 'el evento esta en la biografia de un personaje';
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besado->eventos}), 1, 'el evento esta en la biografia del otro';
	#Y el evento esta en el entorno
	is scalar(grep {$_ eq $evento} @{Entorno->actual->eventos}), 1, 'el evento esta en el entorno';
}

{
	#Cuando el evento esta generado con argumentos para los personajes definidos en los roles
	$builder_evento->build({besador => {sex => 'f', name => 'Mora'}, tipo => 'BESAR'});
	#Entonces se autogeneran personajes segun los parametros
	my $evento = $builder_evento->evento;
	like $evento->description, qr/Mora besa a \w+/, 'se autogeneran personajes' ;
	#Y el evento esta en la biografia de un personaje y del otro
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besador->eventos}), 1, 'el evento esta en la biografia de un personaje';
	is scalar(grep {$_ eq $evento} @{$builder_evento->evento->besado->eventos}), 1, 'el evento esta en la biografia del otro';
	#Y el evento esta en el entorno
	is scalar(grep {$_ eq $evento} @{Entorno->actual->eventos}), 1, 'el evento esta en el entorno';
}
