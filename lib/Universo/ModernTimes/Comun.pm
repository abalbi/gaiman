package ModernTimes::Comun;
use Data::Dumper;
use Universo qw(son tiene El Alteramos);
	sub init {
		my $class = shift;
#		Alteramos concept, 'criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
#		Alteramos concept, [qw(jailbird mafioso)], son 'criminal';
#		Alteramos concept, 'mafioso', tiene resources => [3..5], firearms => [2..5];

		Alteramos concept, 'criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
		Alteramos concept, [qw(jailbird mafioso cat_burglar drug_dealer bandit)], son 'criminal';
		Alteramos concept, 'mafioso', tiene resources => [3..5], firearms => [2..5];

		Alteramos concept, 'dilettante';
		Alteramos concept, [qw(artist writer intellectual gambler student)], son 'dilettante';

		Alteramos concept, 'drifter';
		Alteramos concept, [qw(hobo cowboy prostitute hermit pilgrim)], son 'drifter';

		Alteramos concept, 'entertainer';
		Alteramos concept, [qw(comic musician movie_star clown)], son 'entertainer';

		Alteramos concept, 'investigator';
		Alteramos concept, [qw(detective cop government_agent inquisitor)], son 'investigator';

		Alteramos concept, 'kid';
		Alteramos concept, [qw(child runaway nerd gang_member street_urchin)], son 'kid';
		Alteramos concept, 'nerd', tiene strengh => [1..2], stamina => [1..2];
		Alteramos concept, 'nerd', tiene charisma => [1..2], manipulation => [1..2], appearance => [1..3];
		Alteramos concept, 'nerd', tiene intelligence => [2..5];
		Alteramos concept, 'nerd', tiene athletics => [0..2];
		Alteramos concept, 'nerd', tiene computer => [1..5], academics => [2..5], research => [2..5];

		Alteramos concept, 'outsider';
		Alteramos concept, [qw(aborigine third_world_resident homosexual)], son 'outsider';

		Alteramos concept, 'politician';
		Alteramos concept, [qw(judge mayor senator public_official governor)], son 'politician';

		Alteramos concept, 'professional';
		Alteramos concept, [qw(engineer doctor mortician scholar)], son 'professional';

		Alteramos concept, 'punk';
		Alteramos concept, [qw(club_crawler mosher skinhead classic_70s_punk)], son 'punk';

		Alteramos concept, 'reporter';
		Alteramos concept, [qw(anchorperson newspaper paparazzo town_crier)], son 'reporter';

		Alteramos concept, 'soldier';
		Alteramos concept, [qw(bodyguard mercenary knight)], son 'soldier';

		Alteramos concept, 'worker';
		Alteramos concept, [qw(workertrucker farmer wage_slave servant serf)], son 'worker';


	}
1;



