package ModernTimes::Comun;
use Data::Dumper;
use Universo qw(son tiene El Alteramos);
	sub init {
		my $class = shift;
#		Alteramos concept, 'criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
#		Alteramos concept, [qw(jailbird mafioso)], son 'criminal';
#		Alteramos concept, 'mafioso', tiene resources => [3..5], firearms => [2..5];

		Alteramos concept, 'criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5], dodge => [1..5];
		Alteramos concept, 'criminal', tiene law => [1..5], fame => [0..0];
		Alteramos concept, [qw(jailbird mafioso cat_burglar drug_dealer bandit)], son 'criminal';
		Alteramos concept, 'mafioso', tiene resources => [3..5], firearms => [2..5], fame => [0..3];

		Alteramos concept, 'dilettante', tiene resources => [2..5], fame => [0..3];
		Alteramos concept, 'dilettante', tiene academics => [2..5], expression => [2..5], performance => [2..5];
		Alteramos concept, [qw(artist writer intellectual gambler student)], son 'dilettante';

		Alteramos concept, 'drifter', tiene streetwise => [2..5], survival => [1..5];
		Alteramos concept, 'drifter', tiene resources => [0..2], fame => [0..0];
		Alteramos concept, [qw(hobo cowboy prostitute hermit pilgrim)], son 'drifter';
		Alteramos concept, 'prostitute', tiene appearance => [3..5], manipulation => [1..5];
		Alteramos concept, 'prostitute', tiene subterfuge => [2..5];

		Alteramos concept, 'entertainer', tiene resources => [1..5], performance => [3..5], expression => [1..5], empathy => [1..5];
		Alteramos concept, [qw(comic musician movie_star clown)], son 'entertainer';

		Alteramos concept, 'investigator', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
		Alteramos concept, 'investigator', tiene drive => [2..5], law => [2..5], research => [2..5], investigation => [2..5];
		Alteramos concept, 'investigator', tiene resources => [2..4], fame => [0..1];
		Alteramos concept, 'investigator', tiene perception => [2..5], intelligence => [2..5];
		Alteramos concept, [qw(detective cop government_agent inquisitor)], son 'investigator';

		Alteramos concept, 'kid', tiene academics => [0..1], resources => [0..0];
		Alteramos concept, [qw(child runaway nerd gang_member street_urchin)], son 'kid';
		Alteramos concept, 'nerd', tiene strengh => [1..2], stamina => [1..2];
		Alteramos concept, 'nerd', tiene charisma => [1..2], manipulation => [1..2], appearance => [1..3];
		Alteramos concept, 'nerd', tiene intelligence => [2..5];
		Alteramos concept, 'nerd', tiene athletics => [0..2];
		Alteramos concept, 'nerd', tiene computer => [1..5], academics => [2..5], research => [2..5];

		Alteramos concept, 'outsider', tiene resources => [0..1], fame => [0..1];
		Alteramos concept, [qw(aborigine third_world_resident homosexual)], son 'outsider';

		Alteramos concept, 'politician', 'politician', tiene politics => [1..5], resources => [3..5];
		Alteramos concept, [qw(judge mayor senator public_official governor)], son 'politician';

		Alteramos concept, 'professional', tiene academics => [3..5], resources => [2..5], research => [2..5];
		Alteramos concept, [qw(engineer doctor mortician scholar)], son 'professional';
		Alteramos concept, 'doctor', tiene medicine => [3..5];
		Alteramos concept, 'engineer', tiene science => [3..5];

		Alteramos concept, 'punk', tiene resources => [0..1];
		Alteramos concept, [qw(club_crawler mosher skinhead classic_70s_punk)], son 'punk';

		Alteramos concept, 'reporter', tiene resources => [2..5], fame => [0..5];
		Alteramos concept, [qw(anchorperson newspaper paparazzo town_crier)], son 'reporter';

		Alteramos concept, 'soldier', tiene fame => [0..0];
		Alteramos concept, 'soldier', tiene strengh => [3..5], stamina => [3..5], resources => [2..3];
		Alteramos concept, 'soldier', tiene brawl => [2..5], dodge => [1..5], athletics => [1..5], firearms => [1..5];
		Alteramos concept, [qw(bodyguard mercenary knight)], son 'soldier';
		Alteramos concept, 'bodyguard', tiene intimidation => [2..5];

		Alteramos concept, 'worker', tiene resources => [0..2], fame => [0..0];
		Alteramos concept, [qw(workertrucker farmer wage_slave servant serf)], son 'worker';
		Alteramos concept, 'workertrucker', tiene drive => [2..5];



	}
1;



