package ModernTimes;
use strict;
use base qw(Universo);
use Universo::ModernTimes::Atributo::Tipo;
use Universo::ModernTimes::Builder::Personaje;
use Universo::ModernTimes::Personaje;
use Data::Dumper;
use List::Util qw(shuffle);

sub init {
  my $self = shift;
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'sex',
    validos => [qw(f m)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'name',
    posibles => sub {
      my $atributo_tipo = shift;
      my $sexo = shift;
      if(ref($sexo)) {
        $sexo = $sexo->sex if ref($sexo) ne 'HASH' && $sexo->isa('Personaje');
        $sexo = $sexo->{sex} if ref($sexo) eq 'HASH';
      } 
      my $nombres = [];
      if($sexo eq 'f') {
        $nombres = [qw(Lucia Maria Martina Paula Daniela Sofia Valeria Carla Sara Alba Julia Noa Emma Claudia Carmen Marta Valentina Irene Adriana Ana Laura Elena Alejandra Ines Marina Vera Candela Laia Ariadna Lola Andrea Rocio Angela Vega Nora Jimena Blanca Alicia Clara Olivia Celia Alma Eva Elsa Leyre Natalia Victoria Isabel Cristina Lara Abril Triana Nuria Aroa Carolina Manuela Chloe Mia Mar Gabriela Mara Africa Iria Naia Helena Paola Noelia Nahia Miriam Salma)]
      } else {
        $nombres = [qw(Hugo Daniel Pablo Alejandro Alvaro Adrian David Martin Mario Diego Javier Manuel Lucas Nicolas Marcos Leo Sergio Mateo Izan Alex Iker Marc Jorge Carlos Miguel Antonio Angel Gonzalo Juan Ivan Eric Ruben Samuel Hector Victor Enzo Jose Gabriel Bruno Dario Raul Adam Guillermo Francisco Aaron Jesus Oliver Joel Aitor Pedro Rodrigo Erik Marco Alberto Pau Jaime Asier Luis Rafael Mohamed Dylan Marti Ian Pol Ismael Oscar Andres Alonso Biel Rayan Jan Fernando Thiago Arnau Cristian Gael Ignacio Joan)]
      }
      return $nombres;
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'heir_color',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(moroch[a|o] rubi[a|o] castañ[a|o] peliroj[a|o])],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'heir_long',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(largo corto)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'heir_form',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(lacio ondulado enrulado)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'eyes_color',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(azules verdes marrones negros miel)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'size',
    categoria => 'description',
    subcategoria => 'body',
    validos => [qw(XS S M L XL)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'height',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $personaje->{sex} eq 'f' ? 1.30 : 1.40;
      $medida += .1 if $personaje->{size} eq 'XS';
      $medida += .2 if $personaje->{size} eq 'S';
      $medida += .3 if $personaje->{size} eq 'M';
      $medida += .4 if $personaje->{size} eq 'L';
      $medida += .5 if $personaje->{size} eq 'XL';
      $medida += .1 if $personaje->{stamina} + $personaje->{strengh} >= 8;
      $medida -= .1 if $personaje->{stamina} + $personaje->{strengh} <= 3;
      $medida += (5 - $personaje->{appearance}) * ([-1, 1]->[int rand 2] * .05);
      return $medida;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'weight',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $personaje->{sex} eq 'f' ? 20 : 30;
      $medida += 10 if $personaje->{size} eq 'XS';
      $medida += 20 if $personaje->{size} eq 'S';
      $medida += 30 if $personaje->{size} eq 'M';
      $medida += 40 if $personaje->{size} eq 'L';
      $medida += 50 if $personaje->{size} eq 'XL';
      $medida += 10 if $personaje->{stamina} + $personaje->{strengh} >= 8;
      $medida -= 10 if $personaje->{stamina} + $personaje->{strengh} <= 3;
      $medida += (5 - $personaje->{appearance}) * ([-1, 1]->[int rand 2] * 5);
      return $medida;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'bust',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $personaje->{sex} eq 'f' ? 80 : 90;
      $medida += 4 if $personaje->{size} eq 'XS';
      $medida += 8 if $personaje->{size} eq 'S';
      $medida += 10 if $personaje->{size} eq 'M';
      $medida += 15 if $personaje->{size} eq 'L';
      $medida += 20 if $personaje->{size} eq 'XL';
      $medida += 10 if $personaje->{stamina} + $personaje->{strengh} >= 8;
      $medida -= 10 if $personaje->{stamina} + $personaje->{strengh} <= 3;
      $medida += (5 - $personaje->{appearance}) * ([-1, 1]->[int rand 2] * 2);
      return $medida;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'waist',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $personaje->{sex} eq 'f' ? 50 : 65;
      $medida += 4 if $personaje->{size} eq 'XS';
      $medida += 8 if $personaje->{size} eq 'S';
      $medida += 10 if $personaje->{size} eq 'M';
      $medida += 15 if $personaje->{size} eq 'L';
      $medida += 20 if $personaje->{size} eq 'XL';
      $medida += 10 if $personaje->{stamina} + $personaje->{strengh} >= 8;
      $medida -= 10 if $personaje->{stamina} + $personaje->{strengh} <= 3;
      $medida += (5 - $personaje->{appearance}) * ([-1, 1]->[int rand 2] * 2);
      return $medida;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'hip',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $personaje->{sex} eq 'f' ? 80 : 90;
      $medida += 4 if $personaje->{size} eq 'XS';
      $medida += 8 if $personaje->{size} eq 'S';
      $medida += 10 if $personaje->{size} eq 'M';
      $medida += 15 if $personaje->{size} eq 'L';
      $medida += 20 if $personaje->{size} eq 'XL';
      $medida += 10 if $personaje->{stamina} + $personaje->{strengh} >= 8;
      $medida -= 10 if $personaje->{stamina} + $personaje->{strengh} <= 3;
      $medida += (5 - $personaje->{appearance}) * ([-1, 1]->[int rand 2] * 2);
      return $medida;
    },
  });
  push @{$self->atributo_tipos}, map {ModernTimes::Atributo::Tipo->new({
    nombre => $_,
    validos => [1..5],
    subcategoria => 'virtues',
  })} qw(conviction instinct courage);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'physical',
  })} qw(strengh dexterity stamina);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'social',
  })} qw(manipulation appearance charisma);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'mental',
  })} qw(intelligence perception wits);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'talent',
  })} qw(athletics brawl dodge empathy expression intimidation leadership streetwise subterfuge);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'skill',
  })} qw(animal_ken crafts drive etiquette firearms melee performance security stealth survival);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'knowledge',
  })} qw(academics bureaucracy computer finance investigation law linguistics medicine occult politics research science);

  Gaiman->logger->trace('Se agregaron los atributo_tipos: ',join ',', map {$_->nombre} @{$self->atributo_tipos});
}

  sub es_catetoria {
    my $self = shift;
    my $key = shift;
    foreach my $atributo_tipo (@{$self->atributo_tipos}) {
      return 1 if $atributo_tipo->categoria eq $key;
    }
    return 0;
  }

  sub builder_evento {
    my $self = shift;
    $self->{_builder_evento} = ModernTimes::Builder::Evento->new;
    return $self->{_builder_evento};
  }

  sub builder_personaje {
    my $self = shift;
    $self->{_builder_personaje} = ModernTimes::Builder::Personaje->new;
    return $self->{_builder_personaje};
  }

1;