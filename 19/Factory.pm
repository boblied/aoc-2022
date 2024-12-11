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
    # A geode robot is always worth building
    return 1 if $r == GEODE;
    return $robot->[$r] < $self->blueprint->maxNeededFor($r);
}

my %cache;
sub _run($self, $blueprint, $minutes, $goalRobot, $resource, $robot, $indent)
{
    state $called++;
    return if ( $minutes == 0 );

    my $state = join(' ', $minutes, $goalRobot, $resource->@*, $robot->@*);
    DEBUG "${indent}State: $state";
    if ( $cache{$state}++ )
    {
        DEBUG "${indent}Cache hit $state";
        return;
    }

    # DEBUG showState($blueprint->id, $resource, $robot, $indent);

    my $goalName = resourceName($goalRobot);
    my $s = "Goal $goalName: [$resource->@*][$robot->@*] m-> ";
    _mine($resource, $robot);
    $s .= "[$resource->@*][$robot->@*] b-> ";

    $blueprint->isNewMax($resource->[GEODE]);

    # There is no point in trying to build anything but a geode for the last minute
    # and no point in building anything in the last minute.
    if ( $minutes == 1 )
    {
        DEBUG "${indent}Stop at minute 1, goal $goalName";
        return;
    }
    elsif ( $minutes == 2 )
    {
        DEBUG "${indent}Minute 2, give up on $goalName";
        _mine($resource, $robot);
        $blueprint->isNewMax($resource->[GEODE]);
        return;
    }

    # The best we can possibly do is to add another geode robot
    # every time.  If the max is already greater than that, we can stop.
    # Adding a robot every minute is Sum(n) = n(n+1)/2, but it's n-1
    my $bestPossible = $resource->[GEODE] + ($robot->[GEODE]*$minutes)
                     + ($minutes*($minutes-1)/2 );
    if ( $blueprint->maxGeode > $bestPossible )
    {
        DEBUG "${indent}At min=$minutes, can't beat best, bailing";
        return;
    }

    # If we have enough robots to make a geode robot every time,
    # then we're going to do that. We can calculate how many that's
    # going to be and stop the recursion.
    my @geodeCost = $blueprint->getCost(GEODE);
    if (   $robot->[CLAY] >= $geodeCost[CLAY]
        && $robot->[OBSIDIAN] >= $geodeCost[OBSIDIAN] )
    {
        $resource->[GEODE] += ($robot->[GEODE]*$minutes) + ($minutes*($minutes-1)/2 );
        $blueprint->isNewMax($resource->[GEODE]);
        INFO "${indent}At min=$minutes, Geode bailout";
        return;
    }
    if ( $self->worthBuilding($goalRobot, $resource, $robot) )
    {
        while ( ! $blueprint->canMake($goalRobot, $resource->@* ) )
        {
            # Mine for enough cycles to produce a robot
            my $m = "min=$minutes, mining for $goalName [$resource->@*][$robot->@*] M-> ";
            _mine($resource, $robot);
            DEBUG "$m [$resource->@*][$robot->@*]";
            $minutes--;
            if ( $minutes == 0 )
            {
                # We didn't make the goal robot, but maybe we made some
                # geodes as a side effect of mining.
                $blueprint->isNewMax($resource->[GEODE]);
                DEBUG "${indent}Timed out mining for $goalName";
                return;
            }
        }
        _makeRobot($resource, $robot, $goalRobot, $blueprint->getCost($goalRobot) );
        DEBUG "${indent}min=$minutes Built $s", "[$resource->@*][$robot->@*]";
    }

    # Set a new goal.
    # Everybody needs ore, so that's worth considering,
    # and we need clay as a precursur to obsidian and then geodes.
    # But don't try to create new robot types if we've reached the maximum that
    # would mine enough to build a new robot every cycle.
    if ( $self->worthBuilding(ORE, $resource, $robot) )
    {
        $self->_run($blueprint, $minutes-1, ORE, [$resource->@*], [$robot->@*], "  $indent");
    }
    if ( $self->worthBuilding(CLAY, $resource, $robot) )
    {
        $self->_run($blueprint, $minutes-1, CLAY, [$resource->@*], [$robot->@*], "  $indent");
    }
    # It's only worth considering obsidian if we have at least one clay robot and
    # could profit from making more.
    if ( $robot->[CLAY] > 0  &&  $self->worthBuilding(OBSIDIAN, $resource, $robot) )
    {
        $self->_run($blueprint, $minutes-1, OBSIDIAN, [$resource->@*], [$robot->@*], "  $indent");
    }
    # It's only worth considering geode if we have the ability to make obsidian.
    if ( $robot->[OBSIDIAN] > 0 )
    {
        $self->_run($blueprint, $minutes-1, GEODE, [$resource->@*], [$robot->@*], "  $indent");
    }
}

sub run($self, $minutes)
{
    # Initially we only have an ORE robot, so the only things
    # we can try for are ORE and CLAY robots
    for my $goalRobot ( ORE, CLAY )
    {
        $self->_run($self->blueprint, $minutes, $goalRobot, [ 0, 0, 0, 0], [1, 0, 0, 0], "");
    }
}

sub _makeRobot($resource, $robot, $type, $ore, $clay, $obsidian)
{
    $resource->[ORE] -= $ore;
    $resource->[CLAY] -= $clay;
    $resource->[OBSIDIAN] -= $obsidian;

    $robot->[$type]++;
}

1;
