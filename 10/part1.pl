#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use lib "lib";
use Clock;
use CPU;


my @Program;

while (<>)
{
    chomp;
    my ($instruction, $operand) = split;

    push @Program, [ $instruction, ($operand // 0) ];
}

my $clock = Clock->new;

sub isSampleTime($clock)
{
    return ( ($clock->time - 20 ) % 40) == 0;
}

my $cpu = CPU->new;
$cpu->load(\@Program);

my $signal = 0;
while ( $cpu->isRunning )
{
    $clock->tick();

    if ( isSampleTime($clock) )
    {
        my $signalStrength = $clock->time * $cpu->register;
        $signal += $signalStrength;

        say "TICK: ".$clock->time." X=".$cpu->register
           ." strength=".$signalStrength." SIGNAL=".$signal;
    }

    $cpu->tick();
}
$cpu->show;
