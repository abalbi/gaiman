package Gaiman;
use strict;
use fields qw();
use Log::Log4perl;
use Log::Log4perl::Level;
use JSON;
use Carp qw(confess cluck);

use Personaje;
use Evento;
use Entorno;
use Universo;
use Universo::ModernTimes;
use Data::Dumper;
use Gaiman::Util;

Log::Log4perl->init("log.conf");
our $logger = Log::Log4perl->get_logger("runner");
$Gaiman::logger->level('OFF');
our $instancia;

  sub new {
    my $self = shift;
    my $arg = shift;
    $arg = {} if not defined $arg;
    $arg->{random}  = $arg->{random} ? $arg->{random} : 0;
    $arg->{srand}  = $arg->{srand} ? $arg->{srand} : 8094;
    $arg->{log}    = $arg->{log} ? $arg->{log} : q(OFF);
    $Gaiman::logger->level( $arg->{log} );
    $arg->{srand} = azar 10000 if $arg->{random};
    srand($arg->{srand});
    $logger->info("Random: ".$arg->{srand});
    $self = fields::new($self);
    $self->logger->info("Se instancio ",ref $self);
    return $self;
  }

  sub instancia {
    my $class = shift;
    my $arg = shift;
    $instancia = Gaiman->new($arg) if !$instancia;
    return $instancia;
  }

  sub logger {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    return $logger;
  }

  sub l {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    my $valor = shift;
    $valor = encode_json($valor) if ref $valor;
    $valor = (defined $valor ? "'$valor'" : 'undef');
    return $valor;
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

  sub parrafos {
    my $self = shift;
    $self = $self eq __PACKAGE__ ? $self->instancia : $self;
    my $resultado = join("\n", @_);
    return $resultado;
  }

  sub runner {
    my $class = shift;
    my $arg = shift;
    $arg = {} if !$arg;
    Gaiman->logger->info("Runner argumentos:".encode_json($arg));
    my $srand = 3;
    my $build = $arg->{build};
    delete $arg->{build};
    my $tipo = $arg->{tipo};
    my $random = $arg->{random};
    delete $arg->{random};
    my $json = $arg->{json};
    delete $arg->{json};
    my $detalle = $arg->{detalle};
    delete $arg->{detalle};
    my $log = $arg->{log};
    delete $arg->{log};
    $srand = $arg->{srand};
    delete $arg->{srand};
    my $str = '';
    my $self = Gaiman->instancia;
    my $texto = 1;
    $texto = 0 if $json || $detalle;
    if($build eq 'personaje' || $build eq 'per') {
      ModernTimes->new;
      my $builder = Universo->actual->builder_personaje;
      my $personaje = ModernTimes::Personaje->new;
      $builder->personaje($personaje);
      $builder->build($arg);
      Entorno->actual->agregar($personaje);
      $str .= $personaje->json."\n" if $json;
      $str .= $personaje->detalle."\n" if $detalle;
      $str .= $personaje->description_texto if $texto;
    }
    if($build eq 'evento' || $build eq 'eve') {
      ModernTimes->new;
      my $builder = Universo->actual->builder_evento;
      $builder->build($arg);
      foreach my $key (keys %{$builder->evento->roles}) {
        print Dumper $builder->evento->rol($key)->description_texto;
      }
      $str .= $builder->evento->description;
    }
    return $str;
  }


  sub install {
    my $self = shift;
    Gaiman::logger->info('Dando permisos a gaiman');
    my $gaiman_path = './scripts/gaiman';
    if(!-e $gaiman_path) {
      Gaiman->error('No se encontro '.$gaiman_path);
    }
    Gaiman::logger->info('Chequeando permisos del gaiman');
    if(!-x $gaiman_path) {
      Gaiman::logger->trace('Dando permisos al gaiman');
      chmod 0775, $gaiman_path;
    }
    Gaiman::logger->info('Generando autocomplete en .bashrc');
    my $home_path = $ENV{'HOME'};
    my $bashrc_path = join '/', ($home_path, '.bashrc');
    my $comment = '#Gaiman autocomplete settings';
    my $cmd1 = 'function _getopt_complete() { COMPREPLY=($( COMP_CWORD=$COMP_CWORD perl `which ${COMP_WORDS[0]}` ${COMP_WORDS[@]:0} ));}';
    my $cmd2 = 'complete -F _getopt_complete gaiman';
    if(-e $bashrc_path) {
      open BASHRC, $bashrc_path;
      my @file = <BASHRC>;
      close BASHRC;
      if(! scalar grep {$_ =~ /complete \-F \_getopt\_complete gaiman/} @file) {
        open BASHRC, '>>', $bashrc_path;
        print BASHRC "\n";
        print BASHRC $comment."\n";
        print BASHRC $cmd1."\n";
        print BASHRC $cmd2."\n";
        print BASHRC "\n";
        close BASHRC;
      }
    }
  }
1;

