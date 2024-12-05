#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================


######### Package Node
use v5.36;
package Node;

use Carp qw/croak confess/;
use Moo;

has x => ( is => 'rw', default => 0 );
has y => ( is => 'rw', default => 0 );

sub p($self) { return "($self->{x}, $self->{y})"; }

sub coord($self) { return ( $self->x, $self->y ); }

sub isAdjacent($self, $other)
{
    my $dx = $other->x - $self->x;
    my $dy = $other->y - $self->y;

    return ( abs($dx) <= 1 && abs($dy) <= 1 );
}


sub moveHorz( $self, $dx = 1) { $self->{x} += $dx; return $self; }
sub moveVert( $self, $dy = 1) { $self->{y} += $dy; return $self; }

sub moveLeft( $self, $dx = 1) { $self->{x} -= $dx; return $self; }
sub moveRight($self, $dx = 1) { $self->{x} += $dx; return $self; }
sub moveDown( $self, $dy = 1) { $self->{y} -= $dy; return $self; }
sub moveUp(   $self, $dy = 1) { $self->{y} += $dy; return $self; }

sub moveToward($self, $other)
{
    my $dx = $other->x - $self->x;
    my $dy = $other->y - $self->y;

    return $self if isAdjacent($self, $other);

    if ( $dx == 0 ) # Same column
    {
        return $dy > 0 ? $self->moveUp() : $self->moveDown();
    }
    if ( $dy == 0 ) # Same row
    {
        return $dx > 0 ? $self->moveRight() : $self->moveLeft();
    }

    # Diagonal move to closest row or column
    if ( $dx > 1 )
    {
        $self->moveRight();
        return ( $dy > 0  ? $self->moveUp() : $self->moveDown() );
    }
    elsif ( $dx < -1 )
    {
        $self->moveLeft();
        return ( $dy > 0  ? $self->moveUp() : $self->moveDown() );
    }
    elsif ( $dy > 1 )
    {
        $self->moveUp();
        return ( $dx > 0  ? $self->moveRight() : $self->moveLeft() );
    }
    elsif ( $dy < -1 )
    {
        $self->moveDown();
        return ( $dx > 0  ? $self->moveRight() : $self->moveLeft() );
    }
    else
    { 
        croak("Unexpected difference dx=$dx dy=$dy self=" . $self->p . " other=". $other->p);
    }
}

1;
