use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;

$ModernTimes::Personaje::Builder::Comando::logger->level('INFO');

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
{
	$builder->clean;
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build;
}


{
	#Cuando cargo un comando a un builder
	$builder->comando_carga('attribute', [7,5,3]);
	#Entonces el builder tendra un nuevo comando
	isnt scalar @{$builder->comandos}, 0, 'el builder tendra un nuevo comando';
}

{
	$builder->clean;
	#Cuando cargo un comando para una atributo
	$builder->comando_carga('appearance', 3);
	#Entonces el builder tendra un comando tipo ModernTimes::Personaje::Builder::Comando::Atributo
	isa_ok $builder->comandos->[0], 'ModernTimes::Personaje::Builder::Comando::Atributo';

}

{
	$builder->clean;
	#Cuando cargo un comando para una atributo con un valor
	$builder->comando_carga('appearance', 3);
	#Y la estructura tiene un valor previo
	$builder->estructura->appearance(2);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	#Entonces la estructura tendra el valor
	is $builder->estructura->appearance, 3, 'la estructura tendra el valor';
	ok $comando->hecho, 'el comando estara hecho';
	is $comando->stash->{appearance}, 2, 'el stash del comando contiene el valor anterior';
}


{
	$builder->clean;
	#Cuando cargo un comando para un atributo sin un valor
	$builder->comando_carga('appearance');
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	#Entonces la estructura tendra algun valor valido
	cmp_deeply $builder->estructura->appearance, any(1..5), 'la estructura tendra algun valor valido';
}

{
	$builder->clean;
	#Cuando cargo un comando para una atributo con un valor
	$builder->comando_carga('appearance', 3);
	#Y la estructura tiene un valor previo
	$builder->estructura->appearance(5);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	# Y lo deshago
	$comando->deshacer;
	#Entonces la estructura tendra el valor previo 
	is $builder->estructura->appearance, 5, 'la estructura tendra el valor';
	#Y el comando figurara como no hecho
	is $comando->hecho, 0, 'el comando estara no hecho';
	#Y el stash sera undef
	is $comando->stash, undef, 'el stash sere undef';
}

{
	$builder->clean;
	#Cuando cargo un comando para una subcategoria
	$builder->comando_carga('background', 7);
	#Entonces el builder tendra un comando tipo ModernTimes::Personaje::Builder::Comando::Subcategoria
	isa_ok $builder->comandos->[0], 'ModernTimes::Personaje::Builder::Comando::Subcategoria';

}

