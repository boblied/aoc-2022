#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use strict;
use warnings;
use v5.36;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my %Priority;
{
    for my $i ( 0..25 )
    {
        $Priority{ chr(ord('a')+$i) } =  0 + $i+1;
        $Priority{ chr(ord('A')+$i) } = 26 + $i+1;
    }
}

my @group;
my $elf = 0;
while (<>)
{
    chomp;

    push @group, [ ] if $elf == 0;
    $group[-1][$elf]->{$_}++ for split('', $_);
    $elf = ($elf +1) % 3;
}

my $totalPriority = 0;
for my $g ( @group )
{
    my @both01 = grep { exists( $g->[1]->{$_} ) } keys $g->[0]->%*;
    # say "0 AND 1: [", (sort @both01), "]";

    my @all3 = grep { exists( $g->[2]->{$_} ) } @both01;

    # say "ALL 3: [@all3]";

    if ( @all3 != 1 )
    {
        say "WARN NOT 1: [@all3] ", Dumper($g);
    }

    $totalPriority += $Priority{$all3[0]};
}

say $totalPriority;
