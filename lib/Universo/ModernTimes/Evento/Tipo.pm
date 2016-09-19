package ModernTimes::Evento::Tipo;
use strict;
use fields qw(_nombre _roles _description _epoch );
use Data::Dumper;


sub new {
	my $self = shift;
	my $args = shift;
	$self = fields::new($self);
	$self->{_nombre} = $args->{nombre};
  $self->{_roles} = $args->{roles};
  $self->{_epoch} = $args->{epoch};
  $self->{_description} = $args->{description};
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

sub roles {
  my $self = shift;
  return $self->{_roles};
}

sub description {
  my $self = shift;
  my $contexto = shift;
  my $str;
  if(defined $contexto) {
    $str = &{$self->{_description}}($self,$contexto);
  }
  $str = $contexto->epoch.': '.$str;
  return $str;
}

1;