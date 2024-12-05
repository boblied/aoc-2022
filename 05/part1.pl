#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.36;

use Data::Dumper;

my @stack = map { [] } 0..9;
my @move;

while (<>)
{
    chomp;
    if ( /\[/ )
    {
        # 01234567890123456789012345678901234
        # [Q] [R] [V] [J] [N] [R] [H] [G] [Z]
        #  1   2   3   4   5   6   7   8   9 
        for my $stk ( 1 .. 9 )
        {
            my $s = ($stk-1) * 4 + 1;
            my $crate = substr($_, $s, 1);
            unshift $stack[$stk]->@*, $crate unless $crate eq " ";
        }
    }
    elsif ( /move/ )
    {
        my ($cnt, $from, $to) = /move (\d+) from (\d) to (\d)/;
        push @move, [ $cnt, $from, $to ];
    }
}

for my $move ( @move )
{
    my ($cnt, $from, $to) = $move->@*;
    #say "move $cnt from $from to $to";
    #say "BEFORE: $cnt [$from] ", join(" ", $stack[$from]->@*);
    #say "BEFORE: $cnt [$to] ", join(" ", $stack[$to]->@*);
    while ( $cnt-- )
    {
        push $stack[$to]->@*, pop $stack[$from]->@*;
    }
    #say "AFTER  $cnt [$from] ", join(" ", $stack[$from]->@*);
    #say "AFTER  $cnt [$to] ", join(" ", $stack[$to]->@*);
    #say "-" x 40;
}

for my $s ( 1..9 )
{
    my $crate = $stack[$s][-1] // ".";
    print "$stack[$s][-1]";
}
print "\n";
