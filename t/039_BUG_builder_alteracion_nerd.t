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

#$ModernTimes::Personaje::Builder::logger->level('TRACE');

sub before_each {
	$builder->personaje($personaje);
};

sub after_each {
	$builder->clean;
	$personaje = ModernTimes::Personaje->new;
};


describe "Bug en Alteraciones" => sub {
	context "DADO un builder con un personaje que es nerd" => sub {
		$personaje->concept('nerd');
		context "CUANDO el personaje no tiene ni valores ni argumentos seteados" => sub {
			it "ENTONCES no da error y las sumas dan bien" => sub {
				is $builder->estructura->sum_libres('attribute'), 36;
				is $builder->estructura->sum_defecto('attribute'), 9;
				is $builder->estructura->sum_preasignados('attribute'), 0;
				lives_ok {
					$builder->build;
				};
				is $builder->estructura->sum_asignados('attribute'), 0;
				is $builder->estructura->sum('attribute'), 24;
				cmp_deeply $builder->estructura->sum_posibles('attribute'), [qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)];
				cmp_deeply $builder->estructura->sum_posibles('physical'), [qw(0 1 2 3 4 5 6)];
				cmp_deeply $builder->estructura->sum_posibles('social'), [qw(0 1 2 3 4)];
				cmp_deeply $builder->estructura->sum_posibles('mental'), [qw(1 2 3 4 5 6 7 8 9 10 11 12)];
				cmp_deeply $builder->estructura->sum('physical'), any(qw(8));
				cmp_deeply $builder->estructura->sum('social'), any(qw(6));
				cmp_deeply $builder->estructura->sum('mental'), any(qw(10));
			};
		};
	};
};
