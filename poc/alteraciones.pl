use Data::Dumper;

my $stash = {};

sub concept {
	my $concepts = shift;
	my $arg = shift;
	$concepts = [$concepts] if ref $concepts ne 'ARRAY';
	foreach my $concept (@$concepts) {
		$stash->{$concept} = {} if !$stash->{$concept};
		my $hash = $stash->{$concept};
		$hash->{nombre} = $concept;
		if(exists $arg->{es}) {
			my $es = $arg->{es};
			$arg->{alteraciones} = $stash->{$es}->{alteraciones};
		}
		if(exists $arg->{alteraciones}) {
			foreach my $key (keys %{$arg->{alteraciones}}) {
				$hash->{alteraciones}->{$key} = $arg->{alteraciones}->{$key}
			}
		}
	}
}

sub El { }

sub es {
	my $hash->{es} = shift;
	return $hash;
}

sub son {
	return es(@_);
}

sub tienen {
	return altera(@_);
}

sub tiene {
	return altera(@_);
}

sub altera {
	my $hash->{alteraciones} = {@_};
	return $hash;
}




El concept 'Criminal', tiene streetwise => [2..5], firearms => [1..5], brawl => [1..5];
El concept [qw(Jailbird mafioso)], son 'Criminal';
El concept 'mafioso', tiene resources => [3..5];

print STDERR Dumper [$stash];