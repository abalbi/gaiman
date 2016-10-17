use strict;
use Term::ANSIColor qw(colorstrip);
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Data::Dumper;

$ModernTimes::Personaje::Builder::logger->level('TRACE');

#Dado el uso de Gaiman
use Gaiman;
#Y tener una instancia de ModernTimes
ModernTimes->new;
#Y un builder de personaje
my $builder = Universo->actual->builder_personaje;
{
	#Cuando le hago build en un nuevo personaje
	my $personaje = ModernTimes::Personaje->new;
	$builder->personaje($personaje);
	$builder->build({sex => 'f'});
	#Entonces puedo obtener un detalle del personaje
  like 
    colorstrip($personaje->detalle),
    qr/^\w*
attribute
physical: strengh: \d; dexterity: \d; stamina: \d
social: charisma: \d; manipulation: \d; appearance: \d
mental: perception: \d; intelligence: \d; wits: \d
ability
talent: athletics: \d; brawl: \d; dodge: \d; empathy: \d; expression: \d; intimidation: \d; leadership: \d; streetwise: \d; subterfuge: \d
skill: animal_ken: \d; crafts: \d; drive: \d; etiquette: \d; firearms: \d; melee: \d; performance: \d; security: \d; stealth: \d; survival: \d
knowledge: academics: \d; bureaucracy: \d; computer: \d; finance: \d; investigation: \d; law: \d; linguistics: \d; medicine: \d; occult: \d; politics: \d; research: \d; science: \d
advantage
virtues: conviction: \d; instinct: \d; courage: \d
background: allies: \d; contacts: \d; fame: \d; influence: \d; mentor: \d; resources: \d
\w+ es [\w|ñ]+ de pelo \w+ y \w+. Sus ojos son \w+. Tiene \d\d años. Mide \d.\d\d, pesa \d\d kg y sus medidas son \d\d\d*-\d\d\d*-\d\d\d*./,
    'puedo obtener un detalle del personaje';
}

