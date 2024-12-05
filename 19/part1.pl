#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
#=============================================================================

use v5.36;

use Log::Log4perl qw(:easy);
use Getopt::Long;

use lib ".";

use Blueprint;
use Factory;

Log::Log4perl->easy_init({
    level   => $INFO,
    layout  => '%-5p %m%n'
});

my $Minutes = 24;
GetOptions("minutes=i" => \$Minutes);

INFO "Minutes = $Minutes";

my @BluePrint;

readInput();

my $Quality = 0;
for my $bp ( @BluePrint)
{
    INFO "Try blueprint ", $bp->id;
    my $f = Factory->new(blueprint => $bp);

    $f->run($Minutes);
    INFO $f->show();
    INFO "Blueprint ", $bp->id, " best is ", $bp->maxGeode,
         " quality is ", $bp->quality;
    $Quality += $bp->quality;
}

say "Total quality: $Quality";

sub readInput()
{
    my $bp;
    while (<>)
    {
        chomp;
        if ( m/Blueprint ([0-9]+):/ )
        {
            $bp = Blueprint->new(id => $1);
            push @BluePrint, $bp;
        }
        if ( m/ore robot costs ([0-9]+) ore/ )
        {
            $bp->oreRobotCost( ore => $1 );
        }
        if ( m/clay robot costs ([0-9]+) ore/ )
        {
            $bp->clayRobotCost( ore => $1 );
        }
        if ( m/obsidian robot costs ([0-9]+) ore and ([0-9]+) clay/ )
        {
            $bp->obsidianRobotCost( ore => $1, clay => $2 );
        }
        if ( m/geode robot costs ([0-9]+) ore and ([0-9]+) obsidian/ )
        {
            $bp->geodeRobotCost( ore => $1, obsidian => $2 );
        }
    }

    say $_->show for @BluePrint;
}

