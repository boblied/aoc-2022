#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# rps.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use strict;
use warnings;
use v5.36;

my @Player1 = (
    { A => 'Rock', B => 'Paper', C => 'Scissors' },
);

my @Player2 = (
    { X => 'Rock',  Y => 'Paper',    Z => 'Scissors' },
    { X => 'Rock',  Y => 'Scissors', Z => 'Paper' },
    { X => 'Paper', Y => 'Rock',     Z => 'Scissors' },
    { X => 'Paper', Y => 'Scissors', Z => 'Rock' },
    { X => 'Scissors', Y => 'Paper', Z => 'Rock' },
    { X => 'Scissors', Y => 'Rock',  Z => 'Paper' },
);

my %ItemValue = ( Rock => 1, Paper => 2, Scissors => 3 );
my %GameValue = ( Lose => 0, Draw => 3, Win => 6 );

my %Game = (
    Rock     => { Rock => 'Draw', Paper => 'Lose', Scissors => 'Win'  },
    Paper    => { Rock => 'Win',  Paper => 'Draw', Scissors => 'Lose' },
    Scissors => { Rock => 'Lose', Paper => 'Win',  Scissors => 'Draw' },
);

sub score($item, $outcome)
{
    return $ItemValue{$item} + $GameValue{$outcome}
}

my @Turn;
while (<>)
{
    chomp;
    push @Turn, [ split ];
}

my $p1item = $Player1[0];
my %result;
for my $p2item ( @Player2 )
{
    print "$_ -> $p2item->{$_}\t" for sort keys %$p2item;
    my $totalScore = 0;

    for my $t ( @Turn )
    {
        my $p1uses = $p1item->{$t->[0]};
        my $p2uses = $p2item->{$t->[1]};
        my $outcome = $Game{ $p2uses } { $p1uses };
        my $score = score($p2uses, $outcome);
        $result{$p2uses}{$outcome}++;
        $totalScore += $score;
        # say "@{$t} -> $t->[1]:$p2uses vs $t->[0]:$p1uses: $outcome\t SCORE $score TOTAL $totalScore";
    }
    say "Total Score: $totalScore";
    say "\tWIN  Rock: $result{Rock}{Win}\tPaper:$result{Paper}{Win}\tScissors: $result{Scissors}{Win}";
    say "\tDRAW Rock: $result{Rock}{Draw}\tPaper: $result{Paper}{Draw}\tScissors: $result{Scissors}{Draw}";
    say "\tLOSE Rock: $result{Rock}{Lose}\tPaper: $result{Paper}{Lose}\tScissors: $result{Scissors}{Lose}";
}
