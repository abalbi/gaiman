package ModernTimes;
use strict;
use base qw(Universo);
use Universo::ModernTimes::Atributo::Tipo;
use Universo::ModernTimes::Atributo::Tipo::Fecha;
use Universo::ModernTimes::Atributo::Tipo::Hash;
use Universo::ModernTimes::Atributo::Tipo::Lista;
use Universo::ModernTimes::Atributo::Tipo::Numero;
use Universo::ModernTimes::Atributo::Tipo::Puntos;
use Universo::ModernTimes::Atributo::Tipo::Texto;
use Universo::ModernTimes::Evento;
use Universo::ModernTimes::Evento::Tipo;
use Universo::ModernTimes::Evento::Builder;
use Universo::ModernTimes::Personaje;
use Universo::ModernTimes::Personaje::Builder;
use Data::Dumper;
use DateTime;
use List::Util qw(shuffle);
use JSON;

sub base_date {
  my $self = shift;
  return DateTime->new(year => 1990);  
}

sub init {
  my $self = shift;
  push @{$self->evento_tipos}, ModernTimes::Evento::Tipo->new({
    nombre => 'NACER',
    roles => [qw(sujeto)],
    description => sub {
      my $evento_tipo = shift;
      my $evento = shift;
      my $nace = DateTime->from_epoch(epoch => $evento->sujeto->date_birth);
      my $str = Gaiman->parrafo(
        Gaiman->oracion($evento->sujeto, 
          $evento->sujeto->name,
          'nace',
          'el',
          $nace->strftime('%d de %b de %Y a las %R')

        )
      )
    }
  });
  push @{$self->evento_tipos}, ModernTimes::Evento::Tipo->new({
    nombre => 'BESAR',
    roles => [qw(besador besado)],
    description => sub {
      my $evento_tipo = shift;
      my $evento = shift;
      my $str = Gaiman->parrafo(
        Gaiman->oracion($evento->besador, 
          $evento->besador->name,
          'besa a',
          $evento->besado->name,
        )
      )
    }
  });

  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Lista->new({
    nombre => 'sex',
    validos => [qw(f m)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Numero->new({
    nombre => 'age',
    alguno => sub {
      my $atributo_tipo = shift;
      return 15 + int rand 25;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Fecha->new({
    nombre => 'date_birth',
    alguno => sub {
      my $atributo_tipo = shift;
      my $builder = shift;
      my $age = $builder->estructura->{age};
      my $date_birth;
      while (1) {
        eval {
          $date_birth = DateTime->new(
            year  => Universo->actual->base_date->year - $age,
            month => 1 + int rand 12,
            day => 1 + int rand 31,
            hour => int rand 24,
            minute => int rand 60,
          );
        };
        if($@) {
          next;
        }
        last;
      } 
      return $date_birth->epoch;
    },
    crear_eventos => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $eventos = [];
      my $builder_evento = Universo->actual->builder_evento;
      $builder_evento->build({sujeto => $personaje, tipo => 'NACER', epoch => $personaje->date_birth});
      push @{$eventos}, $builder_evento->evento;
      return $eventos;      
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Texto->new({
    nombre => 'name',
    posibles => sub {
      my $atributo_tipo = shift;
      my $builder = shift;
      my $sexo = $builder->estructura->{sex};
      my $nombres = [];
      if($sexo eq 'f') {
        $nombres = [qw(Lucia Maria Martina Paula Daniela Sofia Valeria Carla Sara Alba Julia Noa Emma Claudia Carmen Marta Valentina Irene Adriana Ana Laura Elena Alejandra Ines Marina Vera Candela Laia Ariadna Lola Andrea Rocio Angela Vega Nora Jimena Blanca Alicia Clara Olivia Celia Alma Eva Elsa Leyre Natalia Victoria Isabel Cristina Lara Abril Triana Nuria Aroa Carolina Manuela Chloe Mia Mar Gabriela Mara Africa Iria Naia Helena Paola Noelia Nahia Miriam Salma)]
      } else {
        $nombres = [qw(Hugo Daniel Pablo Alejandro Alvaro Adrian David Martin Mario Diego Javier Manuel Lucas Nicolas Marcos Leo Sergio Mateo Izan Alex Iker Marc Jorge Carlos Miguel Antonio Angel Gonzalo Juan Ivan Eric Ruben Samuel Hector Victor Enzo Jose Gabriel Bruno Dario Raul Adam Guillermo Francisco Aaron Jesus Oliver Joel Aitor Pedro Rodrigo Erik Marco Alberto Pau Jaime Asier Luis Rafael Mohamed Dylan Marti Ian Pol Ismael Oscar Andres Alonso Biel Rayan Jan Fernando Thiago Arnau Cristian Gael Ignacio Joan)]
      }
      return $nombres;
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Lista->new({
    nombre => 'heir_color',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(moroch[a|o] rubi[a|o] castañ[a|o] peliroj[a|o])],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Lista->new({
    nombre => 'heir_long',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(largo corto)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Lista->new({
    nombre => 'heir_form',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(lacio ondulado enrulado)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Lista->new({
    nombre => 'eyes_color',
    categoria => 'description',
    subcategoria => 'face',
    validos => [qw(azules verdes marrones negros miel)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo::Hash->new({
    nombre => 'body',
    requeridos => [qw(height weight size bust waist hip)],
    alguno => sub {
      my $atributo_tipo = shift;
      my $builder = shift;
      my $valor = shift;
      return $self->crear_biometria($builder, $valor);
    }
  });
  push @{$self->atributo_tipos}, map {ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_,
    validos => [1..5],
    subcategoria => 'virtues',
    categoria => 'advantage',
  })} qw(conviction instinct courage);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'physical',
  })} qw(strengh dexterity stamina);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'social',
  })} qw(charisma manipulation appearance);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'mental',
  })} qw(perception intelligence wits);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'talent',
  })} qw(athletics brawl dodge empathy expression intimidation leadership streetwise subterfuge);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'skill',
  })} qw(animal_ken crafts drive etiquette firearms melee performance security stealth survival);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'ability',
    subcategoria => 'knowledge',
  })} qw(academics bureaucracy computer finance investigation law linguistics medicine occult politics research science);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo::Puntos->new({
    nombre => $_, 
    validos => [0..5], 
    categoria => 'advantage',
    subcategoria => 'background',
  })} qw(allies contacts fame influence mentor resources);

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
    $self->{_builder_evento} = ModernTimes::Evento::Builder->new;
    return $self->{_builder_evento};
  }

  sub builder_personaje {
    my $self = shift;
    $self->{_builder_personaje} = ModernTimes::Personaje::Builder->new;
    return $self->{_builder_personaje};
  }


  sub tabla_biometrica_tallas {
    return {
      XS => [
        { rango_altura => [140..155], rango_peso => [40..50], appearance => [1..2]}, 
      ],
      S => [
        { rango_altura => [140..155], rango_peso => [50..60], appearance => [1..3]}, 
        { rango_altura => [155..170], rango_peso => [40..60], appearance => [1..4]}, 
      ],
      M => [
        { rango_altura => [140..155], rango_peso => [60..70], appearance => [2..4]}, 
        { rango_altura => [155..170], rango_peso => [60..80], appearance => [2..5]}, 
        { rango_altura => [170..185], rango_peso => [50..80], appearance => [2..5]}, 
        { rango_altura => [185..200], rango_peso => [50..70], appearance => [2..5]}, 
      ],
      L => [
        { rango_altura => [170..185], rango_peso => [80..90], appearance => [1..5]}, 
        { rango_altura => [185..200], rango_peso => [70..100], appearance => [1..5]}, 
        { rango_altura => [200..210], rango_peso => [70..100], appearance => [1..5]}, 
      ],
      XL => [
        { rango_altura => [170..185], rango_peso => [90..110], appearance => [1..3]}, 
        { rango_altura => [185..200], rango_peso => [100..110], appearance => [1..3]}, 
        { rango_altura => [200..210], rango_peso => [100..110], appearance => [1..2]}, 
      ]
    }
  }

  sub tabla_biometrica_imc {
    return [
      {nombre => q(delgadez 3), rango => [0..5],    figuras => [qw(rectangulo)]},
      {nombre => q(delgadez 2), rango => [5..10],   figuras => [qw(rectangulo triangulo_invertido)]},
      {nombre => q(delgadez 1), rango => [10..20],  figuras => [qw(rectangulo triangulo reloj_de_arena)]},
      {nombre => q(normal),     rango => [2..25],   figuras => [qw(reloj_de_arena triangulo_invertido)]},
      {nombre => q(obecidad 1), rango => [25..30],  figuras => [qw(triangulo_invertido triangulo)]},
      {nombre => q(obecidad 2), rango => [30..35],  figuras => [qw(ovalo triangulo)]},
      {nombre => q(obecidad 3), rango => [35..100], figuras => [qw(ovalo)]},
    ];

  }

  sub tabla_biometrica_figuras {
    return {
      rectangulo => { medidas => [90,90,90], appearance => [1..3]},
      triangulo => { medidas => [80,60,100], appearance => [2..5]},
      reloj_de_arena => { medidas => [90,60,90], appearance => [2..5]},
      triangulo_invertido => { medidas => [100,80,70], appearance => [2..5]},
      ovalo => { medidas => [90,100,70], appearance => [1..3]},
    }
  }

  sub crear_biometria_altura {
    my $self = shift;
    my $personaje = shift;
    my $height = (int rand 70) + 140;
    $height = $height + (($personaje->{strengh} + $personaje->{stamina}-6)*5);
    $height = $height + ($personaje->{appearance} * ((170 - $height)/6));
    $height -= 10 if $personaje->{sex} eq 'f';
    return $height;
  }

  sub crear_biometria {
    my $self = shift;
    my $builder = shift;
    my $valor = shift;
    my $appearance = $builder->estructura->{appearance};
    my $size = $builder->estructura->{body}->{size};
    my $hash = {};
    my $tbl = $self->tabla_biometrica_tallas;
    my $sizes = [];
    if(!$size) {
      foreach my $key (sort keys %{$tbl}) {
        foreach my $rangos (@{$tbl->{$key}}) {
          push @$sizes, $key if scalar grep {$_ == $appearance} @{$rangos->{appearance}};
        }
      }
      $size = $sizes->[int rand scalar @{$sizes}];
    }
    $hash->{size} = $size;
    my $size_rango = $tbl->{$size}->[int rand scalar @{$tbl->{$size}}];
    my $height = $size_rango->{rango_altura}->[int rand scalar @{$size_rango->{rango_altura}}];
    $height = $height / 100;
    $hash->{height} = $height;
    my $weight = $size_rango->{rango_peso}->[int rand scalar @{$size_rango->{rango_peso}}];
    $hash->{weight} = $weight;

    my $imc = $weight /($height * $height);
    print $imc;
    my $figura;
    foreach my $imc_rango (@{$self->tabla_biometrica_imc}) {
      if($imc > $imc_rango->{rango}->[0] && $imc < $imc_rango->{rango}->[$#{$imc_rango->{rango}}]) {
        my $nombre = $imc_rango->{nombre};
        $figura = $imc_rango->{figuras}->[int rand scalar @{$imc_rango->{figuras}}];
        $hash->{bust} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[0] + ((5 - $appearance) * (int rand 3));
        $hash->{waist} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[1] + ((5 - $appearance) * (int rand 3));
        $hash->{hip} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[2] + ((5 - $appearance) * (int rand 3));
      } 
    }


    return $hash;
  }


1;