package ModernTimes;
use strict;
use base qw(Universo);
use Universo::ModernTimes::Atributo::Tipo;
use Universo::ModernTimes::Builder::Personaje;
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
    nombre => 'description',
    alguno => sub {
      print STDERR Dumper @_;
      my $atributo_tipo = shift;
      my $personaje = shift;
      my $description = {};
      $description->{pelo}->{color} = shuffle(qw(moroch[a|o] rubi[a|o] castañ[a|o] peliroj[a|o] ));
      $description->{ojos}->{color} = shuffle(qw(marrones azules violetas verdes));
      $description->{pelo}->{largo} = shuffle(qw(corto melena largo));
      $description->{medidas}->{alto} = (int(rand(50)) + 150)/100;
      $description->{pelo}->{forma} = shuffle(qw(lacio ondulado enrulado));
      return $description;
    }
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
  Gaiman->logger->trace('Se agregaron los atributo_tipos: ',join ',', map {$_->nombre} @{$self->atributo_tipos});
}

1;