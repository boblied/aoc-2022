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


my $totalPriority = 0;
while (<>)
{
    chomp;
    my ($left, $right) = (substr($_, 0, length($_)/2), substr($_, length($_)/2) );
    # say "[$left][$right]";

    my %manifest;
    $manifest{compartment1}{$_}++ for split('', $left);
    $manifest{compartment2}{$_}++ for split('', $right);

    my @both = grep { exists( $manifest{compartment2}{$_} ) } keys $manifest{compartment1}->%*;

    say "WARN TOO MANY [@both]" if @both > 1;

    $totalPriority += $Priority{$both[0]};
    # say "$both[0] p=$Priority{$both[0]} t=$totalPriority";
}

say $totalPriority;
