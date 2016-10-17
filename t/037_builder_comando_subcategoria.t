use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;
use Test::More::Behaviour;


$ModernTimes::Personaje::Builder::logger->level('TRACE');

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
my $personaje = ModernTimes::Personaje->new;
my $cmd;
my $key = 'social';

sub before_each {
	$builder->personaje($personaje);
};

sub after_each {
	$builder->clean;
	$personaje = ModernTimes::Personaje->new;
};


describe "Comando Subcategoria" => sub {
	context "DADO un builder con un personaje" => sub {
		context "CUANDO el personaje no tiene ni valores ni argumentos seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				is $builder->estructura->sum_libres($key), 12;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 0;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 3;
			};
		};
		context "CUANDO el personaje tiene pero no en los argumentos" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$personaje->appearance(3);
				is $builder->estructura->sum_libres($key), 8;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 2;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 5;
			};
		};
		context "CUANDO tiene argumentos seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				is $builder->estructura->sum_libres($key), 8;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 1;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 4;
			};
		};
		context "CUANDO tiene argumentos y valores en personaje seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				$personaje->manipulation(3);
				is $builder->estructura->sum_libres($key), 4;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 3;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 6;
			};
		};
		context "CUANDO tiene argumentos y valores en personaje que se pisan" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				$personaje->appearance(3);
				is $builder->estructura->sum_libres($key), 8;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 1;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 4;
			};
		};
		context "CUANDO tiene argumentos definidos como ARRAY" => sub {
			it "ENTONCES las sum deben dar correctamente y undef los valores que no se pueden calcular" => sub {
				$builder->argumentos({appearance => [3..5]});
				is $builder->estructura->sum_libres($key), 8;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), undef;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), undef;
			};
		};
		context "CUANDO tiene argumentos definidos como ARRAY" => sub {
			it "ENTONCES las sum deben dar correctamente y undef los valores que no se pueden calcular" => sub {
				$builder->argumentos({appearance => 3});
				$builder->estructura->manipulation(5);
				is $builder->estructura->sum_libres($key), 4;
				is $builder->estructura->sum_defecto($key), 3;
				is $builder->estructura->sum_preasignados($key), 2;
				is $builder->estructura->sum_asignados($key), 4;
				is $builder->estructura->sum($key), 9;
			};
		};
	};
	context "DADO un comando subcategoria" => sub {
		context "CUANDO el comando no tiene puntos" => sub {
			$cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key);
			$cmd->builder($builder);
			it "ENTONCES debe dar un error al hacer el comando" => sub {
				throws_ok {
					$cmd->hacer;
				} qr/Para \w+ es necesario definir los puntos a distribuir en la subcategoria/;
			};
		};
		context "CUANDO el comando tiene puntos" => sub {
			context "CUANDO los puntos asignados son menos que los preasignados" => sub {
				$builder->argumentos({appearance => 5, charisma => 3});
				my $cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, 5);
				$cmd->builder($builder);
				it "ENTONCES debe dar un error" => sub {
					is $builder->estructura->sum_libres($key), 4;
					is $builder->estructura->sum_defecto($key), 3;
					is $builder->estructura->sum_preasignados($key), 6;
					is $builder->estructura->sum_asignados($key), 0;
					is $builder->estructura->sum($key), 9;
					throws_ok {
						$cmd->hacer;
					} qr/Para \w+ los puntos asignados\(\d+\) son menores a los puntos preasignados\(\d+\)./;
				};
			};
			context "CUANDO no hay libres y los puntos asignados distintos a los puntos preasignados" => sub {
				$builder->argumentos({appearance => 2, charisma => 2});
				$personaje->manipulation(2);
				my $cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, 5);
				$cmd->builder($builder);
				it "ENTONCES debe dar un error" => sub {
					throws_ok {
						$cmd->hacer;
					} qr/Para \w+ no hay libres\(\d+\) y los puntos asignados\(\d+\) distintos a los puntos preasignados./;
				};
			};
			context "Y no tenemos atributos con valores previos" => sub {
				my $cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, 7);
				$cmd->builder($builder);
				it "ENTONCES las sumas deben dar bien" => sub {
					$cmd->hacer;
					is $builder->estructura->sum($key), 10;
					is $builder->estructura->sum_libres($key), 5;
					is $builder->estructura->sum_defecto($key), 3;
					is $builder->estructura->sum_asignados($key), 7;
				};
			};
			context "CUANDO el atributo tipo tiene valores minimos distintos al default" => sub {
				my $atributo = $builder->estructura->atributo_tipo('appearance');
				$atributo->validos([4..5]);
				my $cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, 7);
				$cmd->builder($builder);
				it "ENTONCES en la estructura el atributo tendra un valor mayor o igual al minimo Y las sumas deben dar bien" => sub {
					$cmd->hacer;
					cmp_ok($builder->estructura->appearance, '>=', $atributo->validos->[0]);
					is $builder->estructura->sum_libres($key), 5;
					is $builder->estructura->sum_defecto($key), 3;
					is $builder->estructura->sum_preasignados($key), 0;
					is $builder->estructura->sum_asignados($key), 7;
					is $builder->estructura->sum($key), 10;
				};
			};
			context "CUANDO los atributos tienen valores previos" => sub {
				my $cmd = ModernTimes::Personaje::Builder::Comando::Subcategoria->new($key, 7);
				$cmd->builder($builder);
				$personaje->appearance(4);
				it "ENTONCES los valores previos deben ser respetados y las sumas deben dar bien" => sub {
					$cmd->hacer;
					is $builder->estructura->appearance, 4;
					is $builder->estructura->sum_libres($key), 4;
					is $builder->estructura->sum_defecto($key), 3;
					is $builder->estructura->sum_preasignados($key), 3;
					is $builder->estructura->sum_asignados($key), 4;
					is $builder->estructura->sum($key), 10;
				};
			};
		};
	};
};
