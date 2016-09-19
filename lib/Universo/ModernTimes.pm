package ModernTimes;
use strict;
use base qw(Universo);
use Universo::ModernTimes::Atributo::Tipo;
use Universo::ModernTimes::Evento::Tipo;
use Universo::ModernTimes::Personaje::Builder;
use Universo::ModernTimes::Evento::Builder;
use Universo::ModernTimes::Personaje;
use Universo::ModernTimes::Evento;
use Data::Dumper;
use DateTime;
use List::Util qw(shuffle);

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

  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'sex',
    validos => [qw(f m)],
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'age',
    alguno => sub {
      my $atributo_tipo = shift;
      return 15 + int rand 25;
    },
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'date_birth',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $age = $personaje->{age};
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
      $builder_evento->build({sujeto => $personaje, epoch => $personaje->date_birth});
      push @{$eventos}, $builder_evento->evento;
      return $eventos;      
    }
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
    nombre => 'height',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo->nombre};
      return $medida;      
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'weight',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo->nombre};
      return $medida;      
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'size',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo};
      return $medida;
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'bust',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo->nombre};
      return $medida;      
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'waist',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo->nombre};
      return $medida;      
    }
  });
  push @{$self->atributo_tipos}, ModernTimes::Atributo::Tipo->new({
    nombre => 'hip',
    categoria => 'description',
    subcategoria => 'body',
    alguno => sub {
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $medida = $self->crear_biometria($personaje)->{$atributo_tipo->nombre};
      return $medida;      
    }
  });
  push @{$self->atributo_tipos}, map {ModernTimes::Atributo::Tipo->new({
    nombre => $_,
    validos => [1..5],
    subcategoria => 'virtues',
    categoria => 'advantage',
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
  })} qw(charisma manipulation appearance);
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
    nombre => $_, 
    validos => [1..5], 
    categoria => 'attribute',
    subcategoria => 'mental',
  })} qw(perception intelligence wits);
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
  push @{$self->atributo_tipos}, map { ModernTimes::Atributo::Tipo->new({
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

  sub tabla_biometrica_figuras {
    return {
      rectangulo => { medidas => [90,90,90], appearance => [1..3]},
      triangulo => { medidas => [80,60,100], appearance => [2..5]},
      reloj_de_arena => { medidas => [90,60,90], appearance => [2..5]},
      triangulo_invertido => { medidas => [100,80,70], appearance => [2..5]},
      ovalo => { medidas => [90,100,70], appearance => [1..3]},
    }
  }

  sub tabla_biometrica_tallas {
    return {
      XS => [
        { rango_altura => [140..155], rango_peso => [40..50]}, 
      ],
      S => [
        { rango_altura => [140..155], rango_peso => [50..60]}, 
        { rango_altura => [155..170], rango_peso => [40..60]}, 
      ],
      M => [
        { rango_altura => [140..155], rango_peso => [60..70]}, 
        { rango_altura => [155..170], rango_peso => [60..80]}, 
        { rango_altura => [170..185], rango_peso => [50..80]}, 
        { rango_altura => [185..200], rango_peso => [50..70]}, 
      ],
      L => [
        { rango_altura => [170..185], rango_peso => [80..90]}, 
        { rango_altura => [185..200], rango_peso => [70..100]}, 
        { rango_altura => [200..210], rango_peso => [70..100]}, 
      ],
      XL => [
        { rango_altura => [170..185], rango_peso => [90..110]}, 
        { rango_altura => [185..200], rango_peso => [100..110]}, 
        { rango_altura => [200..210], rango_peso => [100..110]}, 
      ]
    }
  }

  sub tabla_biometrica_imc {
    return [
      {nombre => q(delgadez 3), rango => [0..5],    figuras => [qw(rectangulo)]},
      {nombre => q(delgadez 2), rango => [5..10],   figuras => [qw(rectangulo triangulo_invertido)]},
      {nombre => q(delgadez 1), rango => [10..20],  figuras => [qw(rectangulo triangulo reloj_de_arena)]},
      {nombre => q(normal),     rango => [2..25],   figuras => [qw(triangulo_invertido reloj_de_arena triangulo)]},
      {nombre => q(obecidad 1), rango => [25..30],  figuras => [qw(triangulo_invertido triangulo)]},
      {nombre => q(obecidad 2), rango => [30..35],  figuras => [qw(ovalo triangulo)]},
      {nombre => q(obecidad 3), rango => [35..100], figuras => [qw(ovalo)]},
    ];

  }

  sub crear_biometria {
    my $self = shift;
    my $personaje = shift;
    my $hash = {};
    $hash->{height} = $personaje->{height} ? $personaje->{height} : 0;
    $hash->{weight} = $personaje->{weight} ? $personaje->{weight} : 0;
    $hash->{bust} = $personaje->{bust} ? $personaje->{bust} : 0;
    $hash->{waist} = $personaje->{waist} ? $personaje->{waist} : 0;
    $hash->{hip} = $personaje->{hip} ? $personaje->{hip} : 0;
    $hash->{size} = $personaje->{size} ? $personaje->{size} : 0;
    return $hash if $hash->{height} && $hash->{weight} && $hash->{bust} && $hash->{waist} && $hash->{hip};

    $hash->{height} = $hash->{height} + (($personaje->{strengh} + $personaje->{stamina}-6)*5);
    $hash->{height} = $hash->{height} + ($personaje->{appearance} * ((170 - $hash->{height})/6));
    $hash->{weight} = $hash->{weight} + (($personaje->{strengh} + $personaje->{stamina}-6)*5);
    $hash->{weight} = $hash->{weight} + ($personaje->{appearance} * ((70 - $hash->{weight})/6));

    $hash->{size} = [sort keys %{$self->tabla_biometrica_tallas}]->[int rand scalar sort keys %{$self->tabla_biometrica_tallas}];

    while (1) {
      $hash->{height} = (int rand 70) + 140;
      $hash->{height} -= 10 if $personaje->{sex} eq 'f';
      my $next = 0;
      my $rangos = $self->tabla_biometrica_tallas->{$hash->{size}}->[int rand scalar @{$self->tabla_biometrica_tallas->{$hash->{size}}}];
      my $height_min = $rangos->{rango_altura}->[0];
      my $height_max = $rangos->{rango_altura}->[$#{$rangos->{rango_altura}}];
      if($height_max >= $hash->{height} && $height_min <= $hash->{height}) {
        $hash->{weight} = $rangos->{rango_peso}->[int rand $#{$rangos->{rango_peso}}];
        $next = 0;
      } else {
        $next = 1;  
      }
      next if $next;
      last;
    }

    $hash->{height} = $hash->{height} / 100;

    my $figura;
    my $imc = $hash->{weight} /($hash->{height} * $hash->{height});

    my $nombre;
    foreach my $rango (@{$self->tabla_biometrica_imc}) {
      if($imc > $rango->{rango}->[0] && $imc < $rango->{rango}->[$#{$rango->{rango}}]) {
        $nombre = $rango->{nombre};
        $figura = $rango->{figuras}->[int rand scalar @{$rango->{figuras}}];
        $hash->{bust} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[0] + ((5 - $personaje->{appearance}) * (int rand 10));
        $hash->{waist} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[1] + ((5 - $personaje->{appearance}) * (int rand 10));
        $hash->{hip} = $self->tabla_biometrica_figuras->{$figura}->{medidas}->[2] + ((5 - $personaje->{appearance}) * (int rand 10));
      } 
    }
    $hash->{weight} = int $hash->{weight};
    $hash->{height} = sprintf "%.2f", $hash->{height};
    print Dumper $hash;
    return $hash;    
  }

1;