#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
#
# This works for the example, but recurses too deeply on real input.

use v5.36;

my @Map;
my @Me = ( 0, 0 );
my @EndPoint = ( 0, 0 );
my $Start = ord('S');
my $End = ord('E');

while (<>)
{
    chomp;
    if ( ( my $c = index($_, 'S')) >= 0 )
    {
        @Me = ( $., $c+1);
    }
    if ( ( my $c = index($_, 'E')) >= 0 )
    {
        @EndPoint = ( $., $c+1);
    }

    push @Map, [ '|', (split ''), '|' ]; # Plus border
}

my $WIDTH  = scalar($Map[0]->@*);
unshift @Map, [ ('_') x $WIDTH ];
push    @Map, [ ('_') x $WIDTH ];
my $HEIGHT = scalar(@Map);

# Endpoint has elevation 'z'
$Map[ $EndPoint[0] ][ $EndPoint[1] ] = 'z';

say @$_ for @Map;


say "Start= (@Me) End= (@EndPoint)";

my $BestLength = $HEIGHT * $WIDTH;

sub showMap($map) { say @$_ for $map->@*; }

sub cloneMap($map)
{
    my @newMap;
    push @newMap, [ @$_ ] for $map->@*;
    return \@newMap;
}

sub search($row, $col, $pathlen, $map, $pathSoFar)
{
    my $n  = ord(my $nc = $map->[$row-1][$col  ]);
    my $s  = ord(my $sc = $map->[$row+1][$col  ]);
    my $e  = ord(my $ec = $map->[$row  ][$col+1]);
    my $w  = ord(my $wc = $map->[$row  ][$col-1]);

    say "[$row,$col] n=$n s=$s e=$e w=$w";
    if ( $n >= ord('a') && $n <= ord('z') )
    {
        _search($row-1, $col  , $pathlen+1, cloneMap($map), "$pathSoFar$nc" );
    }
    if ( $s >= ord('a') && $s <= ord('z') )
    {
        _search($row+1, $col  , $pathlen+1, cloneMap($map), "$pathSoFar$sc" );
    }
    if ( $e >= ord('a') && $e <= ord('z') )
    {
        _search($row  , $col+1, $pathlen+1, cloneMap($map), "$pathSoFar$ec" );
    }
    if ( $w >= ord('a') && $w <= ord('z') )
    {
        _search($row  , $col-1, $pathlen+1, cloneMap($map), "$pathSoFar$wc" );
    }
}

sub _search($row, $col, $pathlen, $map, $pathSoFar)
{
    my $me = ord(my $mec = $map->[$row][$col]);
    my $n  = ord(my $nc = $map->[$row-1][$col  ]);
    my $s  = ord(my $sc = $map->[$row+1][$col  ]);
    my $e  = ord(my $ec = $map->[$row  ][$col+1]);
    my $w  = ord(my $wc = $map->[$row  ][$col-1]);

    # say ' 'x$pathlen, "[$row,$col] me=$me n=$n s=$s e=$e w=$w len=$pathlen $pathSoFar";
    return if ( $pathlen >= $BestLength );

    if ( $row == $EndPoint[0] && $col == $EndPoint[1] )
    {
        showMap($map);
        say "Found path with length ", $pathlen;
        say "PATH=${pathSoFar}E";
        $BestLength = $pathlen if ( $pathlen < $BestLength );
        return;
    }

    if ( $n >= ($me-1) && $n <= ($me+1) )
    {
        $map->[$row][$col] = '^'; # Mark visited
        _search($row-1, $col, $pathlen+1, cloneMap($map), "$pathSoFar$nc" );
    }
    if ( $s >= ($me-1) && $s <= ($me+1) )
    {
        $map->[$row][$col] = 'V'; # Mark visited
        _search($row+1, $col, $pathlen+1, cloneMap($map), "$pathSoFar$sc" );
    }
    if ( $e >= ($me-1) && $e <= ($me+1) )
    {
        $map->[$row][$col] = '>'; # Mark visited
        _search($row, $col+1, $pathlen+1, cloneMap($map), "$pathSoFar$ec" );
    }
    if ( $w >= ($me-1) && $w <= ($me+1) )
    {
        $map->[$row][$col] = '<'; # Mark visited
        _search($row, $col-1, $pathlen+1, cloneMap($map), "$pathSoFar$wc" );
    }
}

search($Me[0], $Me[1], 0, \@Map, "S");

say "Best: $BestLength";
