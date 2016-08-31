package ModernTimes;
use strict;
use base qw(Universo);
use Universo::ModernTimes::Atributo::Tipo;


sub init {
  my $self = shift;
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'sex',
    validos => [qw(f m)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'name',
  });
}
1;