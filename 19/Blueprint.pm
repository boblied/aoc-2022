# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Blueprint.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

use v5.36;

package Blueprint;

use Moo;
use lib ".";
use Resource;

use List::Util qw(max);
use Log::Log4perl qw/:easy/;

has id => ( is => 'ro', required => 1 );

has cost => ( is => 'ro', default => sub {
                [
                    [0,0,0], # Ore robot: ore, clay, obsidian
                    [0,0,0], # Clay robot: ore, clay, obsidian
                    [0,0,0], # Obsidian robot: ore, clay, obsidian
                    [0,0,0], # Geode robot: ore, clay, obsidian
                ]
            } );
has oreEquivCost => ( is => 'rw', default => sub { [0,0,0,0] } );
has maxNeeded => ( is => 'rw', default => sub { [0,0,0,0] } );

has maxGeode => ( is => 'rw', default => 0 );

sub quality($self)
{
    return $self->maxGeode * $self->id;
}

sub _setRobotCost($self, $robot, %resource)
{
    $self->cost->[$robot][ORE]      = $resource{ore} // 0;
    $self->cost->[$robot][CLAY]     = $resource{clay} // 0;
    $self->cost->[$robot][OBSIDIAN] = $resource{obsidian} // 0;

    $self->calcEquivCost;
    $self->setMaxNeeded;
}

sub oreRobotCost($self, %resource)      { _setRobotCost( $self, ORE, %resource ); }
sub clayRobotCost($self, %resource)     { _setRobotCost( $self, CLAY, %resource ); }
sub obsidianRobotCost($self, %resource) { _setRobotCost( $self, OBSIDIAN, %resource ); }
sub geodeRobotCost($self, %resource)    { _setRobotCost( $self, GEODE, %resource ); }

sub calcEquivCost($self)
{
    my $c = $self->cost;
    my $oreEq   = $c->[ORE][ORE];
    my $clayEq  = $c->[CLAY][ORE] + $oreEq * $c->[CLAY][ORE];
    my $obsidEq = $c->[OBSIDIAN][ORE] + $clayEq * $c->[OBSIDIAN][CLAY];
    my $geodeEq = $c->[GEODE][ORE] + $obsidEq * $c->[GEODE][OBSIDIAN];

    $self->oreEquivCost->[ORE] = $oreEq;
    $self->oreEquivCost->[CLAY] = $clayEq;
    $self->oreEquivCost->[OBSIDIAN] = $obsidEq;
    $self->oreEquivCost->[GEODE] = $geodeEq;
}

sub setMaxNeeded($self)
{
    my $m = $self->maxNeeded;
    for my $r ( ORE, CLAY, OBSIDIAN, GEODE )
    {
        my ($ore, $clay, $obsidian) = $self->getCost($r);
        $m->[ORE]      = $ore      if $ore       > $m->[ORE]      && $r != ORE;
        $m->[CLAY]     = $clay     if $clay      > $m->[CLAY]     && $r != CLAY;
        $m->[OBSIDIAN] = $obsidian if $obsidian  > $m->[OBSIDIAN] && $r != OBSIDIAN;
    }
}

sub maxNeededFor($self, $type)
{
    return $self->maxNeeded->[$type];
}

sub oreEquivalentForRobots($self, $robot)
{
    my $oreEquiv = $self->oreEquivCost->[ORE] * $robot->[ORE]
                 + $self->oreEquivCost->[CLAY] * $robot->[CLAY]
                 + $self->oreEquivCost->[OBSIDIAN] * $robot->[OBSIDIAN];
                 ;
    return $oreEquiv;
}

sub show($self)
{
 my $s  = sprintf("     Blueprint %d  ore  clay  obsidian oreEquiv\n", $self->id);
    $s .= sprintf("      Ore Robot:  %2d   %2d     %2d       %4d\n",
        $self->cost->[ORE]->@*, $self->oreEquivCost->[ORE] );
    $s .= sprintf("     Clay Robot:  %2d   %2d     %2d       %4d\n",
        $self->cost->[CLAY]->@*, $self->oreEquivCost->[CLAY] );
    $s .= sprintf(" Obisdian Robot:  %2d   %2d     %2d       %4d\n",
        $self->cost->[OBSIDIAN]->@*, $self->oreEquivCost->[OBSIDIAN] );
    $s .= sprintf("    Geode Robot:  %2d   %2d     %2d       %4d\n",
        $self->cost->[GEODE]->@*, $self->oreEquivCost->[GEODE] );
}

sub canMake($self, $type, $ore=0, $clay=0, $obsidian=0, $geode=0 )
{
    return ( $ore >= $self->cost->[$type][ORE] &&
            $clay >= $self->cost->[$type][CLAY] &&
        $obsidian >= $self->cost->[$type][OBSIDIAN] )
}

# Return array of ore,clay,obsidian cost
sub getCost($self, $robot)
{
    return $self->cost->[$robot]->@*;
}

sub isNewMax($self, $geode)
{
    if ( $geode > $self->maxGeode )
    {
        $self->maxGeode($geode);
        INFO "BP $self->{id}: new geode Max: $geode";
    }
}

1;
