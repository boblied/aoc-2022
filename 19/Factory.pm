# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Factory.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

use v5.36;


package Factory;
use Log::Log4perl qw(:easy);
use Moo;
use lib ".";

use Resource;

has blueprint => ( is => 'ro', required => 1 );
has robot     => ( is => 'rw', default => sub { [1,0,0,0] } );
has resource  => ( is => 'rw', default => sub { [0,0,0,0] } );


sub _mine($resource, $robot)
{
    for my $r ( ORE, CLAY, OBSIDIAN, GEODE )
    {
        $resource->[$r] += $robot->[$r];
    }
}

sub showState($id, $resource, $robot, $indent="")
{
    # my $s = sprintf("${indent}Factory with blueprint #%d\n", $id);
    my $s = "\n${indent}Resources ore  clay  obsidian geode |  Robots ore clay obsidian geode\n";
    $s .= sprintf("${indent}           %2d    %2d     %2d      %2d  |          %2d   %2d    %2d      %2d\n",
        $resource->@*, $robot->@* );
}

sub show($self)
{
    showState($self->blueprint->id, $self->resource, $self->robot, "");
}

sub worthBuilding($self, $r, $resource, $robot)
{
    state @maxNeeded = (0,0,0);
    if ( $maxNeeded[0] == 0 )
    {
        my $bp = $self->blueprint;
        for my $r ( ORE, CLAY, OBSIDIAN, GEODE )
        {
            my ($ore, $clay, $obsidian) = $self->blueprint->getCost($r);
            $maxNeeded[ORE]      = $ore      if $ore > $maxNeeded[ORE];
            $maxNeeded[CLAY]     = $clay     if $clay > $maxNeeded[CLAY];
            $maxNeeded[OBSIDIAN] = $obsidian if $ore > $maxNeeded[OBSIDIAN];
        }
    }
    # A geode robot is always worth building
    return $r == GEODE || $robot->[$r] < $maxNeeded[$r];
}

sub _run($self, $blueprint, $minutes, $resource, $robot, $indent)
{
    return if ( $minutes == 0 );

    # If there isn't enough time to improve, bail now.
    return if ( $minutes <= $blueprint->maxGeode );

    DEBUG showState($blueprint->id, $resource, $robot, $indent);

    my $s = "[$resource->@*][$robot->@*] --> ";
    _mine($resource, $robot);
    $s .= "[$resource->@*][$robot->@*] --> ";
    if ( $resource->[GEODE] > $blueprint->maxGeode )
    {
        $blueprint->maxGeode($resource->[GEODE]);
        INFO "New geode max for ", $blueprint->id,": ", $resource->[GEODE];
    }

    my @candidate = $blueprint->canMake($resource->@*);
    INFO "${indent}AT min=$minutes, [$resource->@*] can make robots: @candidate";

    @candidate = grep { $self->worthBuilding($_, $resource, $robot) } @candidate;

    # Now try each possible robot
    for my $r ( @candidate )
    {
        my $res = [ $resource->@*];
        my $rob = [ $robot->@* ];
        _makeRobot($res, $rob, $r, $blueprint->getCost($r) );
        INFO "${indent}Made robot $r $s", "[$res->@*][$rob->@*]";
        $self->_run($blueprint, $minutes-1, $res, $rob, "  $indent");
    }

    # Also try without making a robot, just hoarding resources
    {
        my $res = [ $resource->@*];
        my $rob = [ $robot->@* ];
        $self->_run($blueprint, $minutes-1, $res, $rob, "  $indent");
    }
}

sub run($self, $minutes)
{
    $self->_run($self->blueprint, $minutes, [$self->resource->@*], [$self->robot->@*], "");
}

sub _makeRobot($resource, $robot, $type, $ore, $clay, $obsidian)
{
    $resource->[ORE] -= $ore;
    $resource->[CLAY] -= $clay;
    $resource->[OBSIDIAN] -= $obsidian;

    $robot->[$type]++;
}


1;
