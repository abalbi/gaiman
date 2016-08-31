package ModernTimes::Atributo::Tipo;
use strict;
use fields qw(_nombre);

sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self->{_nombre} = $args->{nombre};
	Gaiman->logger->trace("Se instancio ",ref $self);
	return $self;
}
sub es {
	my $self = shift;
	my $key = shift;
	return 1 if $self->nombre eq $key;
	return 0;
}

sub nombre {
  my $self = shift;
  return $self->{_nombre};
}
1;