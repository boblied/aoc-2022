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

my @Entry = (500, 0);

my ($LEFT, $RIGHT, $TOP, $BOTTOM) = ( $Entry[0], $Entry[0], $Entry[1], $Entry[1] );
my $HEIGHT = 0;
my $WIDTH  = 0;


readInput();
fillCaveWithRock();

$Cave[$Entry[1]][$Entry[0]] = '+';

$HEIGHT = $BOTTOM - $TOP + 1;
$WIDTH  = $RIGHT - $LEFT +1;
my $SIZE = ($WIDTH+1) * ($HEIGHT+1);
say "Cave is ($TOP to $BOTTOM = $HEIGHT) x ($LEFT to $RIGHT = $WIDTH) = ", $HEIGHT * $WIDTH;

showCave(\@Cave, $TOP, $BOTTOM, $LEFT, $RIGHT);

my $Sand = 0;
while ( drop(\@Cave, 0, 500) && $Sand <= $SIZE )
{
    ++$Sand;
    showCave(\@Cave, $TOP, $BOTTOM, $LEFT, $RIGHT ) if ( $Sand % 100 == 0 );
}
#$Sand++ while ( drop(\@Cave, 0, 20) && $Sand <= $HEIGHT*$WIDTH );

say "Sand: $Sand";


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

            $LEFT  = $segment[0]->[0] if ( $segment[0]->[0] < $LEFT );
            $LEFT  = $segment[1]->[0] if ( $segment[1]->[0] < $LEFT );

            $RIGHT  = $segment[0]->[0] if ( $segment[0]->[0] > $RIGHT );
            $RIGHT  = $segment[1]->[0] if ( $segment[1]->[0] > $RIGHT );

            $TOP = $segment[0]->[1] if ( $segment[0]->[1] < $TOP );
            $TOP = $segment[1]->[1] if ( $segment[1]->[1] < $TOP );

            $BOTTOM = $segment[0]->[1] if ( $segment[0]->[1] > $BOTTOM );
            $BOTTOM = $segment[1]->[1] if ( $segment[1]->[1] > $BOTTOM );
        }
    }
}

sub showCave($cave, $fromRow = 0, $toRow = 10, $fromCol = 0, $toCol = 10 )
{
    for my $row ( $fromRow .. $toRow)
    {
        say join("", $cave->[$row]->@[$fromCol .. $toCol] );
    }
}

sub fillCaveWithRock()
{
    for my $row ( 0 .. $BOTTOM )
    {
        push @Cave, [ ('.') x ($RIGHT+1) ];
    }

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
            # We've reached the bottom, we would fall into the abyss
            return 0;
        }
        elsif ( $cave->[$row+1][$col] eq '.' )
        {
            $row++;
            $drops++;
        }
        elsif ($col == $LEFT )
        {
            # left would fall into the abyss
            return 0;
        }
        elsif ( $cave->[$row+1][$col-1] eq '.' )
        {
            $row++; $col--;
            $drops++;
        }
        elsif ( $col == $RIGHT )
        {
            # going right falls into the abyss
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
