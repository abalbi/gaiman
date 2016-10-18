use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Test::Deep;
use Data::Dumper;
use Test::More::Behaviour;



sub before_all {
	use_ok('Gaiman::Util')
};

describe "Gaiman Util azar" => sub {
	context "DADO que uso el modulo Gaiman::Util" => sub {
		context "CUANDO ejecuto azar con un entero" => sub {
			my $in = 10000;
			my $res = azar($in);
			it "ENTONCES entonces debe devolverme un entero menor al azar" => sub {
				like $res, qr/\d+/;
			};
		};
		context "CUANDO ejecuto azar con una referencia a un array" => sub {
			my $in = [1,2,3,4,5];
			my $res = azar($in);
			it "ENTONCES entonces debe devolverme un elemento al azar" => sub {
				cmp_deeply $res, any(@$in);
			};
		};
	};
};
