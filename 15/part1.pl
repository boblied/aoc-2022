#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use List::Util qw/uniq/;

use Data::Dumper;
{ no warnings "once"; $Data::Dumper::Sortkeys = 1; }


my $TargetRow = 2000000;
use Getopt::Long;
GetOptions("targetrow=i" => \$TargetRow);

my @SensorBeaconPair;

my ($MinX, $MaxX, $MinY, $MaxY) = (1e8, -1e8, 1e8, -1e8);

readInput();

sub readInput()
{
    my ($sx, $sy, $bx, $by); 
    while (<>)
    {
        chomp;
        ($sx, $sy, $bx, $by) =
        ( $_ =~ m/x=([-0-9]+), y=([-0-9]+): closest beacon is at x=([-0-9]+), y=([-0-9]+)/);
        
        for my $x ( $sx, $bx )
        {
            $MinX = $x if $x < $MinX;
            $MaxX = $x if $x > $MaxX;
        }
        
        for my $y ( $sy, $by )
        {
            $MinY = $y if $y < $MinY;
            $MaxY = $y if $y > $MaxY;
        }

        push @SensorBeaconPair, { sensor => [ $sx, $sy ],
                                  beacon => [ $bx, $by ],
                                  dist   => manDist($sx, $sy, $bx, $by),
                                };
        say "sx=$sx sy=$sy bx=$bx by=$by, dist=", $SensorBeaconPair[-1]->{dist};
    }
}

say "X: [$MinX to $MaxX] Y: [$MinY to $MaxY] Pairs: ", scalar(@SensorBeaconPair), " Row=$TargetRow";
#say "Pairs: ", Dumper(\@SensorBeaconPair);

sub manDist($x1, $y1, $x2, $y2)
{
    return abs($x1-$x2) + abs($y1-$y2);
}

my @xRange;
for my $pair ( @SensorBeaconPair )
{
    # Can the sensor reach the target row?
    my ($sx, $sy) = $pair->{sensor}->@*;

    my $distToRow = abs($sy - $TargetRow);
    next unless $distToRow <= $pair->{dist};
    say "Sensor at ($sx,$sy) can reach row $TargetRow (dist=$pair->{dist})";

    my $xDist = $pair->{dist} - $distToRow;

    push @xRange, [ $sx - $xDist, $sx + $xDist ];

    $MinX = $sx - $xDist if ($sx-$xDist) < $MinX;
    $MaxX = $sx + $xDist if ($sx+$xDist) > $MaxX;

}

sub min($x, $y) { return ( $x < $y ? $x : $y ); }
sub max($x, $y) { return ( $x > $y ? $x : $y ); }

my @sorted = sort { $a->[0] <=> $b->[0] } @xRange;
for my $r ( @sorted )
{
    say "Range: $r->[0] to $r->[1]";
}
my $r = 0;
while ( $r < $#sorted )
{
    my ($r1min, $r1max, $r2min, $r2max) = ( $sorted[$r]->@*, $sorted[$r+1]->@* );
    say "Comparing ($r1min:$r1max to $r2min:$r2max)";

    if ( $r2min <= $r1max && $r2max >= $r1min )
    {
        my @merged = ( min($r1min, $r2min), max($r1max, $r2max) );
        say "Merged to [ @merged ]";
        splice(@sorted, $r, 2, [ @merged ]);
        next;
    }
    $r++;
}

say "$#sorted ranges remain";
my $used = 0;
my $Width = $MaxX - $MinX + 1;
for my $r ( @sorted )
{
    my $cover = $r->[1] - $r->[0] + 1;
    $used += $cover;
    say "$r->[0]:$r->[1] covers $cover, used=$used of $Width";
}
say "Total covered=$used";

# Are there any beacons in this row? Extract their X positions
my @rowBeacon = List::Util::uniqint
                    sort { $a <=> $b }
                    map { $_->{beacon}->[1] }
                    grep { $_->{beacon}->[1] == $TargetRow } @SensorBeaconPair;

say "Beacons in row $TargetRow at @rowBeacon";

# Are the beacons in any of the remaining ranges
my $bInRange = 0;
for my $r ( @sorted )
{
    $bInRange += grep { $_ >= $r->[0] && $_ <= $r->[1] } @rowBeacon;
}
say "After removing beacons, covered=", ($used -= $bInRange);
