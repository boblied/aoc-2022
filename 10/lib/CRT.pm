# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# CRT.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package CRT;

use v5.36;

use Moo;

my $HEIGHT = 6;
my $WIDTH = 40;

has screen => ( is => 'rw', default =>  sub { my @s; push @s, [ ('.')x$WIDTH ] for 1..$HEIGHT; \@s } );
has sprite => ( is => 'rw', default => 0 );
has cycle  => ( is => 'rw', default => 0 );

sub show($self) {
    say join("", $_->@*) for $self->screen->@*
}

sub moveSpriteTo($self, $column)
{
    $self->sprite($column);
}

sub tick($self)
{
    my $row = int($self->cycle / $WIDTH);
    my $pixel = $self->cycle % $WIDTH;
    
    if ( $pixel >= ($self->sprite-1)  && $pixel <= ($self->sprite+1) )
    {
        $self->screen->[$row][$pixel] = '#';
    }
    else
    {
        $self->screen->[$row][$pixel] = ' ';
    }

    my $cycle = ($self->cycle + 1) % ($HEIGHT * $WIDTH);
    $self->cycle($cycle);
}

1;
