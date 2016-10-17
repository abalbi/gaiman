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
$ModernTimes::Personaje::Builder::Comando::logger->level('TRACE');


describe "Alteraciones" => sub {
	context "CUANDO ejecuto el init de ModernTimes::Comun" => sub {
		ModernTimes::Comun->init;
		my $atributo = Universo->actual->atributo_tipo('concept');
		my $primero = (keys %{$atributo->alteraciones})[0];
		it "ENTONCES el atributo afectado tendra las alteraciones" => sub {
			ok scalar values %{$atributo->alteraciones}, 'Tiene alteraciones';
		};
		it "ENTONCES el atributo afectado una alteracion" => sub {
			is ref $atributo->alteraciones->{$primero}, 'HASH';
		};
		it "ENTONCES el atributo afectado una alteracion" => sub {
			is ref $atributo->alteraciones->{$primero}, 'HASH';
		};
	};
	context "CUANDO hago build de un personaje" => sub {
		my $personaje = ModernTimes::Personaje->new;
		$personaje->concept('mafioso');
		$builder->personaje($personaje);
		$builder->build;
		it "ENTONCES el personaje tendra concept" => sub {
			ok $personaje->concept, 'Tiene concept';
		};
		it "ENTONCES el builder tendra las alteraciones propias del valor del concept" => sub {
			my $concept = $personaje->concept;
			cmp_deeply(
				Universo->actual->atributo_tipo("concept")->alteraciones->{$concept}->{firearms},
				$builder->estructura->atributo_tipo("firearms")->validos
			);
		};
		it "ENTONCES el personaje sera como las alteraciones indican" => sub {
			is scalar grep({$personaje->firearms == $_} @{$builder->estructura->atributo_tipo("firearms")->validos}), 1;
		};
	};
};



