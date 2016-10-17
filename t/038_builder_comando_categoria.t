use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;
use Test::More::Behaviour;


#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
my $personaje = ModernTimes::Personaje->new;
my $cmd;
my $key = 'attribute';

sub before_each {
	$builder->personaje($personaje);
};

sub after_each {
	$builder->clean;
	$personaje = ModernTimes::Personaje->new;
};


describe "Comando Categoria" => sub {
	context "DADO un builder con un personaje" => sub {
		context "CUANDO el personaje no tiene ni valores ni argumentos seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				is $builder->estructura->sum_libres($key), 36;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 0;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 9;
			};
		};
		context "CUANDO el personaje tiene pero no en los argumentos" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$personaje->appearance(3);
				is $builder->estructura->sum_libres($key), 32;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 2;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 11;
			};
		};
		context "CUANDO tiene argumentos seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				is $builder->estructura->sum_libres($key), 32;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 1;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 10;
			};
		};
		context "CUANDO tiene argumentos y valores en personaje seteados" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				$personaje->manipulation(3);
				is $builder->estructura->sum_libres($key), 28;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 3;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 12;
			};
		};
		context "CUANDO tiene argumentos y valores en personaje que se pisan" => sub {
			it "ENTONCES las sum deben dar correctamente" => sub {
				$builder->argumentos({appearance => 2});
				$personaje->appearance(3);
				is $builder->estructura->sum_libres($key), 32;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 1;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), 10;
			};
		};
		context "CUANDO tiene argumentos definidos como ARRAY" => sub {
			it "ENTONCES las sum deben dar correctamente y undef los valores que no se pueden calcular" => sub {
				$builder->argumentos({appearance => [3..5]});
				is $builder->estructura->sum_libres($key), 32;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), undef;
				is $builder->estructura->sum_asignados($key), 0;
				is $builder->estructura->sum($key), undef;
			};
		};
	};
	context "DADO un comando categoria" => sub {
		context "CUANDO el comando tiene puntos y no tiene preasignados" => sub {
			$cmd = ModernTimes::Personaje::Builder::Comando::Categoria->new($key, [7,5,3]);
			$cmd->builder($builder);
			it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
				$cmd->hacer;
				is $builder->estructura->sum_libres($key), 21;
				is $builder->estructura->sum_defecto($key), 9;
				is $builder->estructura->sum_preasignados($key), 0;
				is $builder->estructura->sum_asignados($key), 15;
				is $builder->estructura->sum($key), 24;
				cmp_deeply $builder->estructura->sum('physical'), any(qw(6 8 10));
				cmp_deeply $builder->estructura->sum('social'), any(qw(6 8 10));
				cmp_deeply $builder->estructura->sum('mental'), any(qw(6 8 10));
			};
		};
		context "CUANDO el comando tiene puntos y tiene preasignados" => sub {
			$cmd = ModernTimes::Personaje::Builder::Comando::Categoria->new($key, [7,5,3]);
			$cmd->builder($builder);
			context "Y una categoria preasigna igual del terciario" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 2,
					});
					is $builder->estructura->sum_libres($key), 24;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 3;
					$cmd->hacer;
					is $builder->estructura->sum_asignados($key), 12;
					is $builder->estructura->sum($key), 24;
					cmp_deeply $builder->estructura->sum('physical'), any(qw(6));
					cmp_deeply $builder->estructura->sum('social'), any(qw(8 10));
					cmp_deeply $builder->estructura->sum('mental'), any(qw(8 10));
				};
			};
			context "Y una categoria preasigna menor del terciario" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 1,
					});
					is $builder->estructura->sum_libres($key), 24;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 2;
					throws_ok {
						$cmd->hacer;
					} qr/Falla: \w+ no tiene puntos libres, pero sus preasignados\(\d+\) menor a los puntos asignados\(\d+\)/;
				};
			};
			context "Y una categoria preasigna menos o igual del terciario, y otra mayor al terciario pero menor o igual al secundario" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 2,
						appearance => 3,
						charisma => 3,
						manipulation => 2,
					});
					is $builder->estructura->sum_libres($key), 12;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 8;
					$cmd->hacer;
					is $builder->estructura->sum_asignados($key), 7;
					is $builder->estructura->sum($key), 24;
					cmp_deeply $builder->estructura->sum('physical'), any(qw(6));
					cmp_deeply $builder->estructura->sum('social'), any(qw(8));
					cmp_deeply $builder->estructura->sum('mental'), any(qw(10));
				};
			};
			context "Y dos categoria preasigna igual del terciario" => sub {
				it "ENTONCES debe dar un error" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 2,
						appearance => 2,
						charisma => 2,
						manipulation => 2
					});
					is $builder->estructura->sum_libres($key), 12;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 6;
					throws_ok {
						$cmd->hacer;
					} qr/Falla: \w+ no tiene puntos libres, pero sus preasignados\(\d+\) menor a los puntos asignados\(\d+\)/;
				};
			};
			context "Y una categoria preasigna igual del terciario y otra que es mayor que la secundaria pero menor que la primaria" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 2,
						appearance => 4,
						charisma => 4,
					});
					is $builder->estructura->sum_libres($key), 16;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 9;
					$cmd->hacer;
					is $builder->estructura->sum_asignados($key), 6;
					is $builder->estructura->sum($key), 24;
					cmp_deeply $builder->estructura->sum('physical'), any(qw(6));
					cmp_deeply $builder->estructura->sum('social'), any(qw(10));
					cmp_deeply $builder->estructura->sum('mental'), any(qw(8));
				};
			};
			context "Y una categoria preasigna igual del terciario y otra igual a la primaria" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 2,
						dexterity => 2,
						stamina => 2,
						appearance => 5,
						charisma => 4,
					});
					is $builder->estructura->sum_libres($key), 16;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 10;
					$cmd->hacer;
					is $builder->estructura->sum_asignados($key), 5;
					is $builder->estructura->sum($key), 24;
					cmp_deeply $builder->estructura->sum('physical'), any(qw(6));
					cmp_deeply $builder->estructura->sum('social'), any(qw(10));
					cmp_deeply $builder->estructura->sum('mental'), any(qw(8));
				};
			};
			context "Y una categoria preasigna por encima del maximo de los valores" => sub {
				it "ENTONCES debe generar correctamente la estructura y las subcategorias" => sub {
					$builder->argumentos({
						strengh => 4,
						dexterity => 4,
						stamina => 4,
					});
					is $builder->estructura->sum_libres($key), 24;
					is $builder->estructura->sum_defecto($key), 9;
					is $builder->estructura->sum_preasignados($key), 9;
					throws_ok {
						$cmd->hacer;
					} qr/Falla: Para \w+ se estan preasignados \d+, que es mas que el maximo de los valores a repartir/;
				};
			};
		};
	};
};
