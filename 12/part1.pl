#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

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
        @Me = ( $.-1, $c);
    }
    if ( ( my $c = index($_, 'E')) >= 0 )
    {
        @EndPoint = ( $.-1, $c);
    }

    push @Map, [ split '' ];
}

my $HEIGHT = scalar(@Map);
my $WIDTH  = scalar($Map[0]->@*);

# Endpoint has elevation 'z'
$Map[ $EndPoint[0] ][ $EndPoint[1] ] = 'z';

say @$_ for @Map;


say "Start= (@Me) End= (@EndPoint)";

my $SIZE = $HEIGHT * $WIDTH;

my @Dist;
push @Dist, [ ($SIZE) x $WIDTH ] for ( 1 .. $HEIGHT );


$Dist[ $Me[0] ][ $Me[1] ] = 0;

sub reachable($here, $there, $map)
{
    return    (  $there >= ord('a') && $there <= ord('z') )
    #&& ( $there >= ($here-1) && $there <= ($here+1) )
           && ( $there <= ($here+1) )
}

my $VisitCount = 0;

sub search($row, $col, $map, $dist)
{
    if ( $row > 0 )
    {
        my $n  = ord(my $nc = $map->[$row-1][$col  ]);
        if ( $n >= ord('a') && $n <= ord('z') )
        {
            $dist->[$row-1][$col  ] = $dist->[$row][$col] + 1
                if $dist->[$row-1][$col  ] > $dist->[$row][$col] + 1
        }
    }
    if ( $row < $HEIGHT-1 )
    {
        my $s  = ord(my $sc = $map->[$row+1][$col  ]);
        if ( $s >= ord('a') && $s <= ord('z') )
        {
            $dist->[$row+1][$col  ] = $dist->[$row][$col] + 1
                if $dist->[$row+1][$col  ] > $dist->[$row][$col] + 1;
        }
    }
    if ( $col < $WIDTH-1 )
    {
        my $e  = ord(my $ec = $map->[$row  ][$col+1]);
        if ( $e >= ord('a') && $e <= ord('z') )
        {
            $dist->[$row  ][$col+1] = $dist->[$row][$col] + 1
                if $dist->[$row  ][$col+1] > $dist->[$row][$col] + 1;
        }
    }
    if ( $col > 0 )
    {
        my $w  = ord(my $wc = $map->[$row  ][$col-1]);
        if ( $w >= ord('a') && $w <= ord('z') )
        {
            $dist->[$row  ][$col-1] = $dist->[$row][$col] + 1
                if $dist->[$row  ][$col-1] > $dist->[$row][$col] + 1;
        }
    }

    $map->[$row][$col] = '*'; # Mark visited
    ($row, $col) = findMinDist($map, $dist);
    # say "Next: [$row, $col]";

    _search($row, $col, $map, $dist);
}

sub _search($row, $col, $map, $dist)
{
    while ( ++$VisitCount < $SIZE )
    {
        my $me = ord($map->[$row][$col]);

        if ( $row > 0 )
        {
            my $n  = ord(my $nc = $map->[$row-1][$col  ]);
            if ( reachable($me, $n, $map ) )
            {
                if ( $dist->[$row-1][$col] > $dist->[$row][$col] )
                {
                    $dist->[$row-1][$col  ] = $dist->[$row][$col] + 1;
                }
            }
        }
        if ( $row < $HEIGHT-1 )
        {
            my $s  = ord(my $sc = $map->[$row+1][$col  ]);
            if ( reachable($me, $s, $map) )
            {
                if ( $dist->[$row+1][$col] > $dist->[$row][$col] )
                {
                    $dist->[$row+1][$col  ] = $dist->[$row][$col] + 1;
                }
            }
        }
        if ( $col < $WIDTH-1 )
        {
            my $e  = ord(my $ec = $map->[$row  ][$col+1]);
            if ( reachable($me, $e, $map) )
            {
                if ( $dist->[$row  ][$col+1] > $dist->[$row][$col] )
                {
                    $dist->[$row  ][$col+1] = $dist->[$row][$col] + 1;
                }
            }
        }
        if ( $col > 0 )
        {
            my $w  = ord(my $wc = $map->[$row  ][$col-1]);
            if ( reachable($me, $w, $map) )
            {
                if ( $dist->[$row  ][$col-1] > $dist->[$row][$col] )
                {
                    $dist->[$row  ][$col-1] = $dist->[$row][$col] + 1;
                }
            }
        }

        $map->[$row][$col] = '*'; # Mark visited
        last if ( $row == $EndPoint[0] && $col == $EndPoint[1] );

        ($row, $col) = findMinDist($map, $dist);
        say "Next: [$row, $col] $map->[$row][$col] min=$dist->[$row][$col]";

        if ( $row == -1 )
        {
            say "Can't find any more unvisited nodes";
            return;
        }
    }
}


my $MinDist = $SIZE;
sub findMinDist($map, $dist)
{
    my $min = $HEIGHT * $WIDTH;
    my @minLoc = ( -1, -1 );
    for my $row ( 0.. $HEIGHT -1 )
    {
        for my $col ( 0 .. $WIDTH-1 )
        {
            # Only look at unvisited nodes
            my $c = ord( $map->[$row][$col] );
            next unless $c >= ord('a') && $c <= ord('z');

            if ( $dist->[$row][$col] < $min )
            {
                $MinDist = $min = $dist->[$row][$col];
                @minLoc = ( $row, $col );
            }
        }
    }
    return @minLoc;
}

sub showDist($dist, $map)
{
    print "    "; printf("%4d", $_) for ( 0 .. $WIDTH-1); print "\n";

    for my $row ( 0 .. $HEIGHT-1 )
    {
        printf("%4d", $row);
        for my $col ( 0 .. $WIDTH-1 )
        {
            if ( $map->[$row][$col] eq '*' )
            {
                print("    ");
            }
            else
            {
                printf("%4d", $dist->[$row][$col]);
            }
        }
        print "\n";
    }
}

sub showMap($map)
{
    say sprintf("%2d ",$_) , $map->[$_]->@*, " $_" for 0..$HEIGHT-1;
}

sub around($map, $row, $col, $r=1, $c=1)
{
    for ( my $dr = -$r; $dr <= $r; $dr++ )
    {
        for ( my $dc = -$c ; $dc <= $c; $dc++ )
        {
            print "$map->[$row+$dr][$col+$dc] ";
        }
        print "\n";
    }
    #say "$map->[$row-1][$col-1] $map->[$row-1][$col] $map->[$row-1][$col+1]";
    #say "$map->[$row  ][$col-1] $map->[$row  ][$col] $map->[$row  ][$col+1]";
    #say "$map->[$row+1][$col-1] $map->[$row+1][$col] $map->[$row+1][$col+1]";
    #say "$map->[$row+2][$col-1] $map->[$row+2][$col] $map->[$row+2][$col+1]";
}

search( $Me[0], $Me[1], \@Map, \@Dist);
say "MINDIST= $MinDist";
say "Endpoint= $Dist[ $EndPoint[0] ][ $EndPoint[1] ]";
# showDist(\@Dist, \@Map);
showMap(\@Map);
