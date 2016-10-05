use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::More::Behaviour;
use Data::Dumper;
use Test::Warn;

$ModernTimes::Personaje::Builder::logger->level('WARN');
$ModernTimes::Personaje::Builder::Estructura::logger->level('WARN');



#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;


describe "Calculos de Estructura" => sub {
	context "CUANDO tengo un builder sin ejecutar" => sub {
		my $personaje = ModernTimes::Personaje->new;
		$builder->personaje($personaje);
		context "Y sin cambios preasignados" => sub {
			it "ENTONCES tendra los calculos de puntos seran los correctos" => sub {
				is $builder->estructura->sum_defecto('attribute'), 9, 'puntos de defecto'; 
				is $builder->estructura->sum_preseteados('attribute'), 0, 'puntos de preasignados'; 
				is $builder->estructura->sum_libres('attribute'), 36, 'puntos de libres'; 
				is $builder->estructura->sum_defecto('physical'), 3, 'puntos de defecto'; 
				is $builder->estructura->sum_preseteados('physical'), 0, 'puntos de preasignados'; 
				is $builder->estructura->sum_libres('physical'), 12	, 'puntos de libres'; 
			};
		};
		context "Y con cambios preasignados" => sub {
			it "ENTONCES tendra los calculos de puntos seran los correctos" => sub {
	    	$builder->clean;
				$builder->argumentos({sex => 'f', stamina => 3, strengh => 1, manipulation => 1, charisma => 1});
				is $builder->estructura->sum_defecto('attribute'), 9, 'puntos de defecto'; 
				is $builder->estructura->sum_preseteados('attribute'), 2, 'puntos de preasignados'; 
				is $builder->estructura->sum_libres('attribute'), 20, 'puntos de libres'; 
				is $builder->estructura->sum_defecto('physical'), 3, 'puntos de defecto'; 
				is $builder->estructura->sum_preseteados('physical'), 2, 'puntos de preasignados'; 
				is $builder->estructura->sum_libres('physical'), 4, 'puntos de libres'; 
				is $builder->estructura->sum_defecto('social'), 3, 'puntos de defecto'; 
				is $builder->estructura->sum_preseteados('social'), 0, 'puntos de preasignados'; 
				is $builder->estructura->sum_libres('social'), 4, 'puntos de libres'; 
			};
			context "Y los puntos preasignados NO superan el maximo de lo asignado para la subcategoria" => sub {
				it "ENTONCES la validacion de puntos libres contra puntos debe dar ok" => sub {
	    		$builder->clean;
	    		$builder->argumentos({sex => 'f', strengh => 5, stamina => 3});
					ok $builder->estructura->validar_punto_vs_preseteados('physical', 7), 'validar punto vs preseteados';
				}
			};
			context "Y los puntos preasignados SUPERAN el maximo de lo asignado para la subcategoria" => sub {
				it "ENTONCES la validacion de puntos libres contra puntos debe dar nook" => sub {
	    		$builder->clean;
					$builder->argumentos({sex => 'f', strengh => 5, stamina => 3});
					is $builder->estructura->validar_punto_vs_preseteados('physical', 3), 0, 'validar punto vs preseteados';
				}
			};
			context "Y los puntos libres SUPERAN que lo asignado para la subcategoria" => sub {
				it "ENTONCES la validacion de puntos libres contra puntos debe dar nook" => sub {
	    		$builder->clean;
					$builder->argumentos({sex => 'f', strengh => 5, stamina => 3});
					is $builder->estructura->validar_punto_vs_libres('physical', 3), 1, 'validar punto vs preseteados';
				}
			};
			context "Y los puntos libres SON MENOS que lo asignado para la subcategoria" => sub {
				it "ENTONCES la validacion de puntos libres contra puntos debe dar nook" => sub {
	    		$builder->clean;
					$builder->argumentos({sex => 'f', strengh => 5, stamina => 3});
					is $builder->estructura->validar_punto_vs_libres('physical', 7), 0, 'validar punto vs preseteados';
				}
			};
		};
	};
	context "CUANDO tengo un builder al que ejecuto" => sub {
		return;
		$builder->clean;
		my $personaje = ModernTimes::Personaje->new;
		$builder->personaje($personaje);
		context "Y sin cambios preasignados" => sub {
	    $builder->clean;
			$builder->build
		};
		context "Y con cambios preasignados" => sub {
	    $builder->clean;
			$builder->argumentos({sex => 'f', stamina => 3, strengh => 1, manipulation => 1, charisma => 1});
			$builder->build
		};
	};
};



