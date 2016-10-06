use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::More::Behaviour;
use Data::Dumper;
use Test::Warn;
use Test::Deep;

$ModernTimes::Personaje::Builder::logger->level('WARN');
$ModernTimes::Personaje::Builder::Estructura::logger->level('WARN');



#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;


describe "Atributo tipo proxy para Builder::Estructura" => sub {
	context "CUANDO pido un atributo_tipo de una estructura" => sub {
		my $atributo = $builder->estructura->atributo_tipo('appearance');
		my $base = Universo->actual->atributo_tipo('appearance');
		it "ENTONCES el atributo sera un ModernTimes::Personaje::Builder::Estructura::Atributo" => sub {
			isa_ok $atributo, 'ModernTimes::Personaje::Builder::Estructura::Atributo';
		};
		it "Y este Estructura::Atributo tendra todos los metodos de un Tipo base" => sub {
			is $atributo->nombre, 'appearance';
			cmp_deeply $atributo->validos, [1,2,3,4,5];
		};
		context "Y si modifico los validos del Estructura::Atributo" => sub {
			$atributo->validos([3,4,5]);
			it "ENTONCES el Estructura::Atributo me devolvera los nuevos valores" => sub {
				cmp_deeply $atributo->validos, [3,4,5];

			};
			it "PERO no afectar el valor del atributo base" => sub {
				cmp_deeply $base->validos, [1,2,3,4,5];

			};
		};
	};
};



