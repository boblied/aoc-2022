#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Data::Dumper;
{ no warnings "once"; $Data::Dumper::Sortkeys = 1; }


my $Bound = 4000000;
use Getopt::Long;
GetOptions("bound=i" => \$Bound);

my @SensorBeaconPair;
my %Sensor;

my ($MinX, $MaxX, $MinY, $MaxY) = (0, $Bound, 0, $Bound);

sub tuningFrequency($x, $y) { return ($x * $Bound) + $y }

sub manDist($x1, $y1, $x2, $y2)
{
    return abs($x1-$x2) + abs($y1-$y2);
}

sub min($x, $y) { return ( $x < $y ? $x : $y ); }
sub max($x, $y) { return ( $x > $y ? $x : $y ); }

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

sub makeSensorData
{
    for my $p ( @SensorBeaconPair )
    {
        my $s = $p->{sensor};
        my $key = "[$s->[0],$s->[1]]";
        next if exists $Sensor{$key};
        $Sensor{$key}{x}    = $s->[0];
        $Sensor{$key}{y}    = $s->[1];
        $Sensor{$key}{dist} = $p->{dist};
        $Sensor{$key}{minx} = $s->[0] - $p->{dist};
        $Sensor{$key}{maxx} = $s->[0] + $p->{dist};
        $Sensor{$key}{miny} = $s->[1] - $p->{dist};
        $Sensor{$key}{maxy} = $s->[1] + $p->{dist};
    }
}

sub dumpSensor()
{
    my $count = 1;
    for my $s ( sort { $Sensor{$a}{minx} <=> $Sensor{$b}{minx} } keys %Sensor )
    {
        say "$count: ", showSensor($Sensor{$s});
        $count++;
    }
}
sub showSensor($s)
{
    "X:[$s->{minx} $s->{x} $s->{maxx}]\tY:[$s->{miny} $s->{y} $s->{maxy}]\tD: $s->{dist}";
}

sub isInside($x, $y, $sensor)
{
    if ( $x >= $sensor->{minx} && $x <= $sensor->{maxx}
      && $y >= $sensor->{miny} && $y <= $sensor->{maxy} )
    {
        my $d = manDist($x, $y, $sensor->{x}, $sensor->{y});
        if ( $d <= $sensor->{dist} )
        {
            return 1;
        }
    }
    return 0;
}

sub find()
{
    my ($x, $y) = (0, 0);
    my @sorted = sort { $a->{minx} <=> $b->{minx} } values %Sensor;

    while ( $y <= $Bound )
    {
        $x = 0;
        POINT: while ( $x <= $Bound )
        {
            for my $s ( @sorted )
            {
                if ( $y % 1000000  == 0 )
                {
                    say "($x, $y) ", showSensor($s);
                }
                if ( isInside($x, $y, $s) )
                {
                    my $vert = abs($s->{y} - $y);
                    $x = $s->{x} + ( abs($s->{dist} - $vert) + 1 );
                    next POINT; 
                }
            }
            if ( $x <= $Bound )
            {
                say "Found uncovered point at ($x, $y), f=", tuningFrequency($x, $y);
                $x++;
            }
        }
        $y++;
    }
}

readInput();
say "X: [$MinX to $MaxX] Y: [$MinY to $MaxY] Sensors: ", scalar(@SensorBeaconPair);
#say "Pairs: ", Dumper(\@SensorBeaconPair);

makeSensorData();
dumpSensor();

find();

say "DONE";
