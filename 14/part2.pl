#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Data::Dumper;

use lib ".";

my @Cave; # Grid with 0,0 at upper left
my @Rock; # List of segments of rock

my @Entry = ( 0, 500 );

my ($LEFT, $RIGHT, $TOP, $BOTTOM) = ( 0, $Entry[1], 0, $Entry[0] );
my $HEIGHT = 0;
my $WIDTH  = 0;


readInput();
makeCave();
fillCaveWithRock();

$Cave[$Entry[1]][$Entry[0]] = '+';

my $SIZE = ($WIDTH) * ($HEIGHT);
say "Cave height: ($TOP to $BOTTOM = $HEIGHT) x width: ($LEFT to $RIGHT = $WIDTH) = ", $SIZE;

showCave(\@Cave, $TOP, $BOTTOM, $LEFT, $RIGHT);

my $Sand = 0;
while ( drop(\@Cave, 0, 500) && $Sand <= $SIZE )
{
    ++$Sand;
    showCave(\@Cave, $TOP, $BOTTOM, $LEFT, $RIGHT ) if ( $Sand % 100 == 0 );
}
#$Sand++ while ( drop(\@Cave, 0, 20) && $Sand <= $HEIGHT*$WIDTH );

say "Sand: ", $Sand + 1;  # For the cherry on top


sub readInput
{
    while (<>)
    {
        chomp;
        my @corner = split / -> /;

        for my $cor ( 1 .. $#corner )
        {
            my @beg = split(',', $corner[$cor-1]);
            my @end = split(',', $corner[$cor]);

            my @segment = ( [ $beg[0], $beg[1] ],
                            [ $end[0], $end[1] ] );
            push @Rock, [ @segment ];

            $RIGHT  = $segment[0]->[0] if ( $segment[0]->[0] > $RIGHT );
            $RIGHT  = $segment[1]->[0] if ( $segment[1]->[0] > $RIGHT );

            $BOTTOM = $segment[0]->[1] if ( $segment[0]->[1] > $BOTTOM );
            $BOTTOM = $segment[1]->[1] if ( $segment[1]->[1] > $BOTTOM );
        }
    }

    # Double the width to allow for falling to the right
    $RIGHT = $RIGHT * 2; 
    $WIDTH = $RIGHT + 1;
    
    # Add a row at the bottom for the floor.
    $BOTTOM++;
    $HEIGHT = $BOTTOM+1;
}

sub showCave($cave, $fromRow = 0, $toRow = 10, $fromCol = 0, $toCol = 10 )
{
    for my $row ( $fromRow .. $toRow)
    {
        say join("", $cave->[$row]->@[$fromCol .. $toCol] );
    }
}

sub makeCave()
{
    # Maximim width is a 45-degree pyramid from the entry point

    for my $row ( 0 .. $BOTTOM )
    {
        push @Cave, [ ('.') x $WIDTH ];
    }
    # Bottom row is rock
    push @Cave,  [ ('#') x $WIDTH ];
    $BOTTOM++;
    $HEIGHT++;
}

sub fillCaveWithRock()
{
    for my $r ( @Rock )
    {
        if ( (my $column = $r->[0]->[0] ) == $r->[1]->[0] )
        {
            my ($from, $to) = ( $r->[0]->[1], $r->[1]->[1] );
            if ( $to < $from ) { ( $from, $to) = ($to, $from ); }
            $Cave[$_][$column] = '#' for ( $from .. $to );
        }
        elsif ( (my $row = $r->[0]->[1]) == $r->[1]->[1] )
        {
            my ($from, $to) = ( $r->[0]->[0], $r->[1]->[0] );
            if ( $to < $from ) { ( $from, $to) = ($to, $from ); }
            $Cave[$row][$_] = '#' for ( $from .. $to );
        }
        else
        {
            die "Unexpected segment ".Dumper($r);
        }
    }
}

sub drop($cave, $row, $col)
{
    my $drops = 0;
    while ( ( $TOP <= $row <= $BOTTOM ) && ( $LEFT <= $col <= $RIGHT ) )
    {
        if ( $row == $BOTTOM )
        {
            # We've reached the bottom, okay if space is available
            if ( $cave->[$row][$col] eq '.' )
            {
                $cave->[$row][$col] = 'o';
                return 1;
            }
            return 0;
        }
        elsif ( $cave->[$row+1][$col] eq '.' )
        {
            $row++;
            $drops++;
        }
        elsif ($col == $LEFT )
        {
            warn "Hit left wall at ($row, $col), sand=$Sand";
            return 0;
        }
        elsif ( $cave->[$row+1][$col-1] eq '.' )
        {
            $row++; $col--;
            $drops++;
        }
        elsif ( $col == $RIGHT )
        {
            warn "Hit right wall at ($row, $col), sand=$Sand";
            return 0;
        }
        elsif ( $cave->[$row+1][$col+1] eq '.' )
        {
            $row++, $col++;
            $drops++;
        }
        else
        {
            if ( $drops == 0 )
            {
                return 0;
            }
            else
            {
                $cave->[$row][$col] = 'o';
                return 1;
            }
        }
    }
    return 0;
}
