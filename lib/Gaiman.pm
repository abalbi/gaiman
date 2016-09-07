package Gaiman;
use strict;
use fields qw();
use Log::Log4perl;
use Log::Log4perl::Level;
use JSON;

use Personaje;
use Entorno;
use Universo;
use Universo::ModernTimes;
use Data::Dumper;

srand(3);
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

  sub t {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    my $personaje = shift;
    my $string = shift;
    my $resultado = $string;
    $resultado =~ s/\[(.+)\]//;
    my @letras = split(/\|/, $1) if $1;
    $resultado = $resultado . $letras[0] if $letras[0] && $personaje->sex eq 'f';
    $resultado = $resultado . $letras[1] if $letras[1] && $personaje->sex eq 'm';
    $resultado =~ s/_/ /gi;
    $self->logger->trace('t: ',$string, ' -> ', $resultado);
    return $resultado;
  }

  sub oracion {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    my $sujeto = shift;
    my $resultado = join(' ', map {Gaiman->t($sujeto, $_)} @_);
    $resultado =~ s/ ,/,/g;
    $resultado =~ s/  / /g;
    $resultado .= '.';
    return $resultado;
  }

  sub parrafo {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    my $resultado = join(' ', @_);
    return $resultado;
  }

  sub runner {
    my $class = shift;
    my $arg = shift if ref $_[0] eq 'ARRAY';
    my $arg = {@_} if !$arg;
    my $comando = $arg->{comando};
    delete $arg->{comando};
    my $random = $arg->{random};
    delete $arg->{random};
    my $json = $arg->{json};
    delete $arg->{json};
    my $log = $arg->{log};
    delete $arg->{log};
    my $str = '';
    srand()  if $random;
    srand(3) if !$random;
    my $pre_log = $Gaiman::logger->level;
    $Gaiman::logger->level( $log );
    Gaiman->logger->info("Runner argumentos:".encode_json($arg));
    my $self = Gaiman->instancia;
    if($comando eq 'personaje' || $comando eq 'per') {
      ModernTimes->new;
      my $builder = ModernTimes::Builder::Personaje->new;
      my $personaje = ModernTimes::Personaje->new;
      $builder->personaje($personaje);
      $builder->build($arg);
      Entorno->actual->agregar($personaje);
      $str .= $personaje->json."\n" if $json;
      $str .= $personaje->description_texto
    }
    $Gaiman::logger->level( $pre_log );
    return $str;
  }
1;