#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use lib "lib";
use CPU;
use CRT;

my @Program;

sub readInput
{
    while (<>)
    {
        chomp;
        my ($instruction, $operand) = split;

        push @Program, [ $instruction, ($operand // 0) ];
    }
}

readInput();

my $crt = CRT->new;
my $cpu = CPU->new;

$cpu->load(\@Program);

while ( $cpu->tick()->isRunning )
{
    $crt->tick();
    $crt->moveSpriteTo($cpu->register);
}
$crt->show;
