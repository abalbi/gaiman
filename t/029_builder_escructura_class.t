use strict;
use lib 'lib';
use Test::More qw(no_plan);;
use Test::Exception;
use Test::Output;
use Data::Dumper;
use Test::Warn;

$ModernTimes::Personaje::Builder::logger->level('TRACE');

diag qq(DADO el uso de Gaiman y una instancia de ModernTimes y usando su builder y con un personaje);
use Gaiman;
ModernTimes->new;
my $builder = Universo->actual->builder_personaje->clean;
{   
    my $personaje = $builder->personaje(Personaje->new);
    diag qq(CUANDO tengo una estructura de builder limpia);
    my $estructura = $builder->estructura;
    my $atributo = Universo->actual->atributo_tipo('sex');
    isa_ok $estructura, 'ModernTimes::Personaje::Builder::Estructura', 'ENTONCES sera de la clase Estructura';
    is $estructura->sex, $atributo->defecto, 'Y cualquier atributo sera undef';
}

{
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino un argumento con valor);
    $builder->argumentos->{sex} = 'f';
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor';
}

{
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    $builder->personaje->sex('f');
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino al personaje un atributo con valor);
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor';
}
{
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino al personaje un atributo con valor);
    $personaje->sex('m');
    diag qq(CUANDO defino un argumento con valor);
    $builder->argumentos->{sex} = 'f';
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor del argumento';
}

{
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino al personaje un atributo con valor);
    $personaje->sex('m');
    diag qq(CUANDO defino por parametro el atributo en la estructura);
    $estructura->sex('f');
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor del parametro';

}

warning_is {
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino al personaje un atributo con valor);
    $personaje->sex('f');
    diag qq(CUANDO defino un argumento con valor invalido);
    $builder->argumentos->{sex} = 'x';
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor del personaje';
} 'No es valido el valor x para el atributo sex', 'ENTONCES manda un warning cuando es invalido';

warning_is {
    diag qq(CUANDO tengo una estructura de builder limpia);
    $builder->clean;
    my $personaje = $builder->personaje(Personaje->new);
    my $estructura = $builder->estructura;
    diag qq(CUANDO defino al personaje un atributo con valor);
    $personaje->sex('f');
    diag qq(CUANDO defino un argumento con valor invalido);
    $estructura->sex('x');
    is $estructura->sex, 'f', 'ENTONCES el atributo tendra el valor del personaje';
} 'No es valido el valor \'x\' para el atributo sex', 'ENTONCES manda un warning cuando es invalido';


