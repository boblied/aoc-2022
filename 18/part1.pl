#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

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

        push @Point, [$x,$y,$z];

        $MaxX = $x if $x > $MaxX;
        $MaxY = $y if $y > $MaxY;
        $MaxZ = $z if $z > $MaxZ;
        $MinX = $x if $x < $MinX;
        $MinY = $y if $y < $MinY;
        $MinZ = $z if $z < $MinZ;
    }
}

say scalar(@Point), " points";
say "X: $MinX to $MaxX";
say "Y: $MinY to $MaxY";
say "Y: $MinZ to $MaxZ";

my @Space; # 3d array


for my $p (@Point)
{
    my ($x, $y, $z) = $p->@*;

    $Space[$x][$y][$z] = 6;
}

for my $p ( @Point )
{
    my ($x, $y, $z) = $p->@*;
    $Space[$x][$y][$z]-- if $x > $MinX && exists $Space[$x-1][$y  ][$z  ];
    $Space[$x][$y][$z]-- if $x < $MaxX && exists $Space[$x+1][$y  ][$z  ];
    $Space[$x][$y][$z]-- if $y > $MinY && exists $Space[$x  ][$y-1][$z  ];
    $Space[$x][$y][$z]-- if $y < $MaxY && exists $Space[$x  ][$y+1][$z  ];
    $Space[$x][$y][$z]-- if $z > $MinZ && exists $Space[$x  ][$y  ][$z-1];
    $Space[$x][$y][$z]-- if $z < $MaxZ && exists $Space[$x  ][$y  ][$z+1];
}

my $Surface = 0;
for my $p ( @Point )
{
    my ($x, $y, $z) = $p->@*;
    $Surface += $Space[$x][$y][$z]
}

say $Surface;

