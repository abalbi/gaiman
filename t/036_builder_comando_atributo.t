use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;
use Test::More::Behaviour;


$ModernTimes::Personaje::Builder::Comando::logger->level('TRACE');

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;

describe "Comando Atributo" => sub {
	context "DADO un builder con un personaje" => sub {
		my $puntos = 3;
		my $valor_personaje = 2;
		my $valor_argumento = 4;
		context "Y un comando de un atributo SIN puntos" => sub {
			my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction');
			$cmd->builder($builder);
			context "CUANDO el builder NO tiene argumentos" => sub {
				context "Y el personaje NO tiene valor en el atributo" => sub {
					it "ENTONCES el valor del comando debe ser undef" => sub {
						is $cmd->puntos, undef;
					};
				};
				context "CUANDO el personaje TIENE valor en el atributo" => sub {
					$builder->clean;
					my $personaje = ModernTimes::Personaje->new();
					$personaje->conviction($valor_personaje);
					$builder->personaje($personaje);
					it "ENTONCES el valor del comando debe ser el del personaje" => sub {
						is $cmd->puntos, $valor_personaje;
					};
				};
			};
			context "CUANDO el builder tiene argumentos definidos para el atributo" => sub {
				context "CUANDO el personaje NO tiene valor en el atributo" => sub {
					$builder->clean;
					my $personaje = ModernTimes::Personaje->new();
					$builder->personaje($personaje);
					$builder->argumentos({conviction => $valor_argumento});
					it "ENTONCES el valor del comando ser el del argumento" => sub {
						is $cmd->puntos, $valor_argumento;
					};
				};
				context "CUANDO el personaje TIENE valor en el atributo" => sub {
					$builder->clean;
					my $personaje = ModernTimes::Personaje->new();
					$personaje->conviction($valor_personaje);
					$builder->personaje($personaje);
					$builder->argumentos({conviction => $valor_argumento});
					it "ENTONCES el valor del comando ser el del argumento" => sub {
						is $cmd->puntos, $valor_argumento;
					};
				};
			};
		};
		context "Y un comando de un atributo CON puntos" => sub {
			$builder->clean;
			my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction', $puntos);
			$cmd->builder($builder);
			my $personaje = ModernTimes::Personaje->new();
			$builder->personaje($personaje);
			it "ENTONCES el valor del comando debe ser undef" => sub {
				is $cmd->puntos, $puntos;
			};
		};
	};
	context "DADO un builder con un personaje" => sub {
		my $valor_valido = 4;
		my $valor_invalido = 6;
		my $array_valores = [2..4];
		context "CUANDO un comando atributo con puntos UNDEF" => sub {
			$builder->clean;
			my $personaje = ModernTimes::Personaje->new();
			$builder->personaje($personaje);
			my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction');
			$cmd->builder($builder);
			$cmd->hacer;
			it "ENTONCES la estructura debe tener un valor valido" => sub {
				cmp_deeply $builder->estructura->conviction, any(@{$builder->estructura->atributo_tipo('conviction')->validos});
			};
			context "CUANDO un comando atributo CON puntos asignados" => sub {
				context "Y puntos es un scalar" => sub {
					$builder->clean;
					my $personaje = ModernTimes::Personaje->new();
					$builder->personaje($personaje);
					my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction', $valor_valido);
					$cmd->builder($builder);
					$cmd->hacer;
					it "ENTONCES la estructura debe tener el valor" => sub {
						is $builder->estructura->conviction, $valor_valido;
					};
					context "Y puntos son un valor invalido" => sub {
						$builder->clean;
						my $personaje = ModernTimes::Personaje->new();
						$builder->personaje($personaje);
						my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction', $valor_invalido);
						$cmd->builder($builder);
						throws_ok {
							$cmd->hacer;
						} qr/No se valido 6 para el atributo conviction \'\["1","2","3","4","5"\]\'/;
						it "ENTONCES la estructura debe tener el valor UNDEF" => sub {
							is $builder->estructura->conviction, 1;
						};
					};
				};
				context "Y puntos es un ARRAY" => sub {
					$builder->clean;
					my $personaje = ModernTimes::Personaje->new();
					$builder->personaje($personaje);
					my $cmd = ModernTimes::Personaje::Builder::Comando::Atributo->new('conviction', $array_valores);
					$cmd->builder($builder);
					$cmd->hacer;
					it "ENTONCES la estructura debe tener el valor dentro del ARRAY" => sub {
						cmp_deeply $builder->estructura->conviction, any(@{$array_valores});
					};
				};
			};
		};
	};
};
