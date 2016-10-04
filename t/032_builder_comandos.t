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

{
	$builder->clean;
	#Cuando cargo un comando para una subcategoria con un valor
	$builder->comando_carga('background', 7);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	#Entonces la estructura tendra valores para los miembros de la subcategoria
	is $builder->estructura->sum('background'), 7, 'la estructura tendra el valor';
	ok $comando->hecho, 'el comando estara hecho';
	cmp_deeply $comando->stash, {
		allies => 0,
		contacts => 0,
		fame => 0,
		influence => 0,
		mentor => 0,
		resources => 0,
	} ,'el stash del comando tendra valores previos';
	#Y la estructura tendra los valores correspondientes
	cmp_deeply $builder->estructura->valores('background'), {
		allies => any(0..5),
		contacts => any(0..5),
		fame => any(0..5),
		influence => any(0..5),
		mentor => any(0..5),
		resources => any(0..5),
	} ,'la estructura tendra los valores correspondientes';
}

{
	$builder->clean;
	#Cuando cargo un comando para una subcategoria con un valor
	$builder->comando_carga('background', 7);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	# Y lo deshago
	$comando->deshacer;
	#Entonces la estructura tendra el valor previo 
	is $builder->estructura->sum('background'), 0, 'la estructura tendra el valor';
	#Y el comando figurara como no hecho
	is $comando->hecho, 0, 'el comando estara no hecho';
	#Y el stash sera undef
	is $comando->stash, undef, 'el stash sere undef';
	#Y la estructura tendra los valores correspondientes
	cmp_deeply $builder->estructura->valores('background'), {
		allies => 0,
		contacts => 0,
		fame => 0,
		influence => 0,
		mentor => 0,
		resources => 0,
	} ,'la estructura tendra los valores correspondientes';
}


{
	$builder->clean;
	#Cuando cargo un comando para una categotia
	$builder->comando_carga('attribute', [7,5,3]);
	#Entonces el builder tendra un comando tipo ModernTimes::Personaje::Builder::Comando::Categoria
	isa_ok $builder->comandos->[0], 'ModernTimes::Personaje::Builder::Comando::Categoria';
}

{
	$builder->clean;
	#Cuando cargo un comando para una subcategoria con un valor
	$builder->comando_carga('attribute', [7,5,3]);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	#Entonces la estructura tendra valores para los miembros de la subcategoria
	is $builder->estructura->sum('attribute'), 24, 'la estructura tendra el valor';
	ok $comando->hecho, 'el comando estara hecho';
	cmp_deeply $comando->stash, {
		appearance => 1,
		charisma => 1,
		dexterity => 1,
		intelligence => 1,
		manipulation => 1,
		perception => 1,
		stamina => 1,
		strengh => 1,
		wits => 1,
	} ,'el stash del comando tendra valores previos';
	#Y la estructura tendra los valores correspondientes
	cmp_deeply $builder->estructura->valores('attribute'), {
		appearance => any(1..5),
		charisma => any(1..5),
		dexterity => any(1..5),
		intelligence => any(1..5),
		manipulation => any(1..5),
		perception => any(1..5),
		stamina => any(1..5),
		strengh => any(1..5),
		wits => any(1..5),
	} ,'la estructura tendra los valores correspondientes';
}

{
	$builder->clean;
	#Cuando cargo un comando para una subcategoria con un valor
	$builder->comando_carga('attribute', [7,5,3]);
	# Y lo ejecuto
	my $comando = $builder->comandos->[0];
	$comando->hacer;
	# Y lo deshago
	$comando->deshacer;
	#Entonces la estructura tendra valores para los miembros de la subcategoria
	is $builder->estructura->sum('attribute'), 9, 'la estructura tendra el valor';
	#Y el comando figurara como no hecho
	is $comando->hecho, 0, 'el comando estara no hecho';
	#Y el stash sera undef
	is $comando->stash, undef, 'el stash sere undef';
	#Y la estructura tendra los valores correspondientes
	cmp_deeply $builder->estructura->valores('attribute'), {
		appearance => 1,
		charisma => 1,
		dexterity => 1,
		intelligence => 1,
		manipulation => 1,
		perception => 1,
		stamina => 1,
		strengh => 1,
		wits => 1,
	} ,'la estructura tendra los valores correspondientes';
}


