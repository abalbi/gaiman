use strict;
use Data::Dumper;
use Term::ANSIColor qw(colorstrip);
my $file = $ARGV[0];
open my $fh, $file;
my $lines = [<$fh>];
close $fh;

my $use_behaviour = scalar grep {$_ =~ qr/use Test\:\:More\:\:Behaviour\;/} @$lines;

print "$file\n";
if ($use_behaviour) {
	my $cmd = 'prove -v '.$file;
	my $result = [`$cmd`];
	$result = [grep {$_ !~ qr/^ok/} @$result];
	$result = [grep {$_ !~ qr/^1\.\.\d+/} @$result];
	$result = [grep {$_ !~ qr/^All tests successful./} @$result];
	$result = [grep {$_ !~ qr/^Files=\d+, Tests=\d+/} @$result];
	$result = [grep {$_ !~ qr/^Result: \w+/} @$result];
	$result = [grep {$_ !~ qr/$file/} @$result];
	foreach my $line (@$result) {
		chomp($line);
		$line = colorstrip($line);
		next if !$line;
		next if $line =~ /^use/;
		next if $line =~ qr/^\[\d+\]/;
		$line =~ s/ (Entonces|Dado|Cuando|Y|Pero)/ \*\*$1\*\*/i;
		$line =~ s/^(\w)/\n$1/;
		print $line."\n";
	}
} else {
	foreach my $line (@$lines) {
		chomp($line);
		next if !$line;
		next if $line =~ /^use/;
		if($line !~ /\#/) {
			$line = "`$line`";
		} else {
		  $line =~ s/\#(Entonces|Dado|Cuando|Y)/\#\*\*$1\*\*/;
		}
		print $line."\n";
	}
} 
