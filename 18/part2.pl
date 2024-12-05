#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Data::Dumper;

use constant EMPTY     => 0;
use constant LAVA      => 1;
use constant REACHABLE => 2;
use constant QUEUED    => 3;

my @Point;
my ($MaxX, $MaxY, $MaxZ) = (0,0,0);
my ($MinX, $MinY, $MinZ) = ( 0xfffffff, 0xfffffff, 0xfffffff );

readInput();

sub readInput()
{
    while (<>)
    {
        chomp;
        my ($x, $y, $z) = split ',';

        # Add one to avoid 0-index boundary hassle.
        $x++; $y++; $z++;
        push @Point, [$x,$y,$z];

        $MaxX = $x if $x > $MaxX;
        $MaxY = $y if $y > $MaxY;
        $MaxZ = $z if $z > $MaxZ;
        $MinX = $x if $x < $MinX;
        $MinY = $y if $y < $MinY;
        $MinZ = $z if $z < $MinZ;
    }
}
# Make sure we put an empty border around the cube.
$MaxX++; $MaxY++; $MaxZ++;

say scalar(@Point), " points";
say "X: $MinX to $MaxX";
say "Y: $MinY to $MaxY";
say "Y: $MinZ to $MaxZ";

my @Space; # 3d array


for my $p (@Point)
{
    my ($x, $y, $z) = $p->@*;

    $Space[$x][$y][$z] = LAVA;
}

# Assuming all non-negative points near the origin
for ( my $x = 0 ; $x <= $MaxX+1 ; $x++ )
{
    for ( my $y = 0 ; $y <= $MaxY+1 ; $y++ )
    {
        for ( my $z = 0 ; $z <= $MaxZ+1 ; $z++ )
        {
            $Space[$x][$y][$z] = EMPTY if not defined $Space[$x][$y][$z];
        }
    }
}

sub neighbors($p)
{
    my ($x,$y,$z) = $p->@*;
    my @n;

    push @n, [ $x-1, $y, $z] if ( $x > 0 );
    push @n, [ $x+1, $y, $z] if ( $x < $MaxX );
    push @n, [ $x, $y-1, $z] if ( $y > 0 );
    push @n, [ $x, $y+1, $z] if ( $y < $MaxY );
    push @n, [ $x, $y, $z-1] if ( $z > 0 );
    push @n, [ $x, $y, $z+1] if ( $z < $MaxZ );

    return @n;
}

sub getSpace($p)
{
    my ($x,$y,$z) = $p->@*;
    return $Space[$x][$y][$z];
}

sub setSpace($p, $val)
{
    my ($x,$y,$z) = $p->@*;
    $Space[$x][$y][$z] = $val;
}

sub showSpace()
{
    for ( my $z = 0; $z <= $MaxZ ; $z++ )
    {
        showLayer($z);
        print "\n";
    }
}

sub showLayer($z)
{
    for ( my $y = $MaxY; $y >= 0 ; $y-- )
    {
        printf("Z=%2d %2d: ", $z, $y);
        for ( my $x = 0; $x <= $MaxX ; $x++ )
        {
            printf("%3d ", getSpace([$x,$y,$z]) );
        }
        print "\n";
    }
    print "         "; print ("----"    ) for 0 .. $MaxX; print "\n";
    print "         "; printf("%3d ", $_) for 0 .. $MaxX; print "\n";
}

showSpace();

# From the (0,0,0) corner, do breadth-first search to touch every
# point that is reachable on the outside. That should leave only
# interior points marked as EMPTY.

my @ToDo = ( [0,0,0] );

reach();

# Everything is now either REACHABLE, LAVA, or EMPTY.  The outside
# should all be REACHABLE, and only the internal holes that weren't
# marked as LAVA or REACHABLE are left EMPTY.

sub reach()
{
    my $count = 0;
    while ( my $p = shift @ToDo )
    {
        $count++;
        my $c = getSpace($p);
        setSpace($p, REACHABLE) if $c == EMPTY || $c == QUEUED;
        for my $n ( emptyNeighbors($p) )
        {
            setSpace($n, QUEUED);
            push @ToDo, $n;
        }
        say "Reach progress $count" if $count %200 == 0;
    }
}

showSpace();

sub emptyNeighbors($p)
{
    my @e = grep { getSpace($_) == EMPTY } neighbors($p);
    return @e;
}

sub lavaNeighbors($p)
{
    my $ln = 0;
    for my $n ( neighbors($p) )
    {
        $ln++ if getSpace($n) == LAVA;
    }
    return $ln;
}

# Calculate the surface area as in part 1.  This counts surfaces
# both on the outside (next to REACHABLE) and inside (next to EMPTY).
#
# Also calculate the surface area of the holes, in the same manner
# except that we are looking for empty neighbor cells.
#
# The net surface are is the difference.
my $surface = 0;
my $hole = 0;
for ( my $x = 0 ; $x <= $MaxX ; $x++ )
{
    for ( my $y = 0 ; $y <= $MaxY ; $y++ )
    {
        for ( my $z = 0 ; $z <= $MaxZ ; $z++ )
        {
            my $p = [ $x,$y,$z ];
            my $c = getSpace($p);
            if ( $c == LAVA )
            {
                $surface += (6 - lavaNeighbors($p));
            }
            elsif ( $c == EMPTY )
            {
                $hole += (6 - emptyNeighbors($p));
            }
        }
    }
}

say "SURFACE: $surface";
say "HOLES: $hole";
say "NET: $surface - $hole = ", $surface - $hole;

# Alternate calculation.  Only add the surface area of LAVA
# cells that have a REACHABLE neighbor.
$surface = 0;
for ( my $x = 0 ; $x <= $MaxX ; $x++ )
{
    for ( my $y = 0 ; $y <= $MaxY ; $y++ )
    {
        for ( my $z = 0 ; $z <= $MaxZ ; $z++ )
        {
            my $p = [ $x,$y,$z ];
            my $c = getSpace($p);
            if ( $c == LAVA )
            {
                my @N = neighbors($p);
                if ( grep { getSpace($_) == REACHABLE } @N )
                {
                    $surface += (6 - lavaNeighbors($p));
                }
            }
        }
    }
}

say "ALTERNATE: $surface";
# Too high

# Third alternative.  Turn all the empty space into lava so
# that only external surfaces count.
for ( my $x = 0 ; $x <= $MaxX ; $x++ )
{
    for ( my $y = 0 ; $y <= $MaxY ; $y++ )
    {
        for ( my $z = 0 ; $z <= $MaxZ ; $z++ )
        {
            my $p = [ $x,$y,$z ];
            my $c = getSpace($p);
            setSpace($p, LAVA) if ( $c == EMPTY );
        }
    }
}

$surface = 0;
for ( my $x = 0 ; $x <= $MaxX ; $x++ )
{
    for ( my $y = 0 ; $y <= $MaxY ; $y++ )
    {
        for ( my $z = 0 ; $z <= $MaxZ ; $z++ )
        {
            my $p = [ $x,$y,$z ];
            my $c = getSpace($p);
            if ( $c == LAVA )
            {
                $surface += (6 - lavaNeighbors($p));
            }
        }
    }
}

say "ALTERNATE 2: $surface";
