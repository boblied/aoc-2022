#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use strict;
use warnings;
use v5.36;

my %Player1 = ( A => 'Rock', B => 'Paper', C => 'Scissors' );

my %Result = ( X => 'Lose', Y => 'Draw', Z => 'Win' );

my %ToGet = (
    Rock =>     { Win => 'Paper',    Draw => 'Rock',     Lose => 'Scissors' },
    Paper =>    { Win => 'Scissors', Draw => 'Paper',    Lose => 'Rock' },
    Scissors => { Win => 'Rock',     Draw => 'Scissors', Lose => 'Paper' },
);

my %ItemValue = ( Rock => 1, Paper => 2, Scissors => 3 );
my %GameValue = ( Lose => 0, Draw => 3, Win => 6 );

sub score($item, $outcome) { return $ItemValue{$item} + $GameValue{$outcome} }

my @Turn;
while (<>)
{
    chomp;
    push @Turn, [ split ];
}

my $totalScore;
for my $t ( @Turn )
{
    my ($opponentUses, $wantedResult) = ( $Player1{$t->[0]}, $Result{$t->[1]} );

    my $youUse = $ToGet{$opponentUses}{$wantedResult};

    my $s = score($youUse, $wantedResult);
    $totalScore += $s;

    # say "$opponentUses($t->[0]) vs $youUse -> $wantedResult($t->[1])  SCORE=$s TOTAL=$totalScore";
}

say $totalScore;
