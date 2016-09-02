use strict;
my $file = $ARGV[0];
open my $fh, $file;
my $lines = [<$fh>];
close $fh;

print "#$file\n";
foreach my $line (@$lines) {
	chomp($line);
	next if !$line;
	next if $line =~ /^use/;
	if($line !~ /\#/) {
		$line = "`$line`";
	} else {
	  $line =~ s/\#(Entonces|Dado|Cuando)/\#\*\*$1\*\*/;
	}
	print $line."\n";
}
