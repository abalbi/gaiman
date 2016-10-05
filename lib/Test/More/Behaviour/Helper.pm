package Test::More::Behaviour::Helper;

use strict;
use warnings;


use Data::Dumper;
use Exporter qw(import);
use Test::More;
use Term::ANSIColor qw(colored);

our @EXPORT = qw(evaluate_and_print_subtest spec_description context_description);

my $spec_description;
my $context_description;
my $passed = 1;

my $description_stash = [];

sub evaluate_and_print_subtest {
  my ($description, $block) = @_;

  print _subtest(_construct_description($description) => _subtest_block($block));

  return;
}

sub _subtest {
  my ($description, $block) = @_;

  $block->();
  return $description->(),"\n";
}

sub _subtest_block {
  my $block = shift;

  return sub {
    eval {
      $passed = $block->();
      1;
    } or do {
      $passed = 0;
      fail($@);
    };
  };
}

sub _construct_description {
  my $result = shift;
;

  my $c = 0;
  my $description_array = [];
  foreach my $item (@$description_stash) {
    $description_array->[$c] = (' ' x $c).$item;
    $c++;
  }
  my $return = join("\n", @$description_array)."\n".(' ' x scalar(@$description_array)).$result;
  return sub { colored [_color()], $return };
}

sub _color {
  return $passed ? 'green' : 'red';
}

sub spec_description { $spec_description = shift; push @$description_stash, $spec_description}
sub context_description { 
  $context_description = shift; 
  if($context_description) {
    push @$description_stash, $context_description 
  } else {
    pop @$description_stash;
  }
}

1;
