package Gaiman;
use strict;
use fields qw();

use Log::Log4perl;
use Log::Log4perl::Level;
Log::Log4perl->init("log.conf");
our $logger = Log::Log4perl->get_logger("runner");

our $instancia;
  sub new {
    my $self = shift;
    my $args = shift;
    $self = fields::new($self);
    $self->logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub instancia {
    my $class = shift;
    $instancia = Gaiman->new if !$instancia;
    return $instancia;
  }

  sub logger {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    return $logger;
  }
1;