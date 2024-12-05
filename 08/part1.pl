#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

my @Tree;
my $row = 0;
while (<>)
{
    chomp;
    $Tree[$row++] = [ split // ];
}

sub dumpArray($g)
{
    for my $row ( 0 .. (scalar(@$g)-1) )
    {
        say join("", $g->[$row]->@*);
    }
}

dumpArray(\@Tree);

my $height = scalar(@Tree) - 1;
my $width = scalar(@{$Tree[0]}) - 1;

my @Visible;
for my $row ( 0 .. $height )
{
    $Visible[$row] = [ (1) x ($width+1) ];
}

dumpArray(\@Visible);

DOWN: for my $row ( 1 .. $height - 1 )
{
    ACROSS: for my $col ( 1 .. $width - 1 )
    {
        my $tree = $Tree[$row][$col];
        print "\n$row,$col [$tree]";
        my $hidden = 0;
        for ( my $west = 0 ; $west < $col ; $west++ )
        {
            if ( $Tree[$row][$west] >= $tree )
            {
                $hidden++;
                print "W";
                last;
            }
        }
        for ( my $east = $width ; $east > $col; $east-- )
        {
            if ( $Tree[$row][$east] >= $tree )
            {
                $hidden++;
                print "E";
                last;
            }
        }
        for ( my $north = 0; $north < $row ; $north++ )
        {
            if ( $Tree[$north][$col] >= $tree )
            {
                $hidden++;
                print "N";
                last;
            }
        }
        for ( my $south = $height ; $south > $row ; $south-- )
        {
            if ( $Tree[$south][$col] >= $tree )
            {
                $hidden++;
                print "S";
                last;
            }
        }
        $Visible[$row][$col] = 0 if ( $hidden == 4 );
    }
}

print "\n";
# dumpArray(\@Visible);

my $count = 0;
for my $row ( 0 .. $height )
{
    for my $col ( 0 .. $width )
    {
        $count+= $Visible[$row][$col];
    }
}

say "COUNT: ($height X $width) $count";
