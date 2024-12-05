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

has id => ( is => 'ro', required => 1 );

has cost => ( is => 'ro', default => sub {
                    [ [0,0,0] ], # Ore robot: ore, clay, obsidian
                    [ [0,0,0] ], # Clay robot: ore, clay, obsidian
                    [ [0,0,0] ], # Obsidian robot: ore, clay, obsidian
                    [ [0,0,0] ], # Geode robot: ore, clay, obsidian
            } );
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
}

sub oreRobotCost($self, %resource)      { _setRobotCost( $self, ORE, %resource ); }
sub clayRobotCost($self, %resource)     { _setRobotCost( $self, CLAY, %resource ); }
sub obsidianRobotCost($self, %resource) { _setRobotCost( $self, OBSIDIAN, %resource ); }
sub geodeRobotCost($self, %resource)    { _setRobotCost( $self, GEODE, %resource ); }

sub show($self)
{
 my $s  = sprintf("     Blueprint %d  ore  clay  obsidian\n", $self->id);
    $s .= sprintf("      Ore Robot:  %2d   %2d     %2d\n",
        $self->cost->[ORE]->@* );
    $s .= sprintf("     Clay Robot:  %2d   %2d     %2d\n",
        $self->cost->[CLAY]->@* );
    $s .= sprintf(" Obisdian Robot:  %2d   %2d     %2d\n",
        $self->cost->[OBSIDIAN]->@* );
    $s .= sprintf("    Geode Robot:  %2d   %2d     %2d\n",
        $self->cost->[GEODE]->@* );
}

sub canMake($self, $ore=0, $clay=0, $obsidian=0, $geode=0 )
{
    my @robot = ();
    my $cost = $self->cost;
    # Try to build the costliest first
    for my $r ( GEODE, OBSIDIAN, CLAY, ORE )
    {
        if (     $ore >= $cost->[$r][ORE] &&
                $clay >= $cost->[$r][CLAY] &&
            $obsidian >= $cost->[$r][OBSIDIAN] )
        {
            push @robot, $r;
        }
    }
    return @robot;
}

# Return array of ore,clay,obsidian cost
sub getCost($self, $robot)
{
    return $self->cost->[$robot]->@*;
}

1;
