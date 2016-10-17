package ModernTimes::Comun;
use Data::Dumper;
use Universo qw(son tiene El Alteramos);
	sub init {
		my $class = shift;
		Alteramos concept, 'criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
		Alteramos concept, [qw(jailbird mafioso)], son 'criminal';
		Alteramos concept, 'mafioso', tiene resources => [3..5], firearms => [2..5];
	}
1;