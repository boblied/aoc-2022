#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use List::Util qw/max product/;

my @Tree;
my $row = 0;
while (<>)
{
    chomp;
    $Tree[$row++] = [ split // ];
}

sub dumpArray($g, $sep = "")
{
    for my $row ( 0 .. (scalar(@$g)-1) )
    {
        say join($sep, $g->[$row]->@*);
    }
}

# dumpArray(\@Tree, " ");

my $height = scalar(@Tree) - 1;
my $width = scalar(@{$Tree[0]}) - 1;

my @Score;
for my $row ( 0 .. $height )
{
    $Score[$row] = [ (1) x ($width+1) ];
}

DOWN: for my $row ( 1 .. $height - 1 )
{
    ACROSS: for my $col ( 1 .. $width - 1 )
    {
        my $tree = $Tree[$row][$col];
        my @distance = (0, 0, 0, 0);

        my $west = $col - 1;
        while ( $west > 0 )
        {
            last if $Tree[$row][$west] >= $tree;
            $west--;
        }
        $distance[0] = $col - $west;

        my $east = $col + 1;
        while ( $east < $width )
        {
            last if $Tree[$row][$east] >= $tree;
            $east++;
        }
        $distance[1] = $east - $col;

        my $north = $row - 1;
        while ( $north > 0 )
        {
            last if $Tree[$north][$col] >= $tree;
            $north--;
        }
        $distance[2] = $row - $north;

        my $south = $row + 1;
        while ( $south < $height )
        {
            last if $Tree[$south][$col] >= $tree;
            $south++;
        }
        $distance[3] = $south - $row;

        $Score[$row][$col] = List::Util::product(@distance);

        # say "[$row][$col] = [@distance] -> $Score[$row][$col]";
    }
}

print "\n";
# dumpArray(\@Score, " ");

my $best = 0;
for my $row ( 0 .. $height )
{
    my $bestInRow = List::Util::max( $Score[$row]->@* );

    $best= $bestInRow if ( $bestInRow > $best );
}

say "BEST: $best"
