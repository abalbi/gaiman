use strict;
use Term::ANSIColor qw(colorstrip);
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Data::Dumper;

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
{
	#Cuando le hago build a un personaje definiendo que es de app 5
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({appearance => 5});
	#Entonces el personaje tendra datos de description body logicos
	like $personaje->body->{size}, qr/^(M|L)$/, 'tiene size';
}
{
	#Cuando le hago build a un personaje definiendo que es de app 4
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({appearance => 4});
	#Entonces el personaje tendra datos de description body logicos
	like $personaje->body->{size}, qr/^(S|M|L)$/, 'tiene size';
}
{
	#Cuando le hago build a un personaje definiendo que es de app 3
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({appearance => 3});
	#Entonces el personaje tendra datos de description body logicos
	like $personaje->body->{size}, qr/^(XS|S|M|L|XL)$/, 'tiene size';
}
{
	#Cuando le hago build a un personaje definiendo que es de app 2
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({appearance => 2});
	#Entonces el personaje tendra datos de description body logicos
	like $personaje->body->{size}, qr/^(XS|S|M|L|XL)$/, 'tiene size';
}
{
	#Cuando le hago build a un personaje definiendo que es de app 1
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({appearance => 1});
	#Entonces el personaje tendra datos de description body logicos
	like $personaje->body->{size}, qr/^(XS|S|L|XL)$/, 'tiene size';
}
