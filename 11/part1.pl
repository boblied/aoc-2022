#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use lib "lib";
use Monkey;

my @Monkey;

sub readInput
{
    local $/ = ""; # Paragraph at a time
    push @Monkey, Monkey::parse($_) while (<> );
}

readInput();
Monkey::setCollection(\@Monkey);

say scalar(@Monkey), " monkeys";

for my $round ( 1 ..  10000 )
{
    for my $monkey ( @Monkey )
    {
        # 3say "MONKEY ", $monkey->id;
        # for my $m ( @Monkey ) { say "  ROUND $round BEFORE: ", $m->showList; }
        $monkey->takeTurn();
        # for my $m ( @Monkey ) { say "  ROUND $round AFTER:  ", $m->showList; }
    }

    if ( $round % 1000 == 0 )
    {
        say "ROUND $round";
        for my $m (@Monkey )
        {
            say "Monkey ".$m->id." inspected items ".$m->inspectCount." times";
        }
    }
}


my @sorted = sort { $b <=> $a } map { $_->inspectCount } @Monkey;

say "$sorted[0] * $sorted[1] = ", $sorted[0] * $sorted[1];
