#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# calories.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use strict;
use warnings;
use v5.30;

use experimental qw/ signatures /;
no warnings "experimental::signatures";

use List::Util qw/sum/;

my @elfCalories = ( 0 );
my $elf = 1;
while (<> )
{
    if ( /^$/ )
    {
        $elf++;
        next;
    }

    $elfCalories[$elf] += $_;
}

my @sorted = sort { $elfCalories[$a] <=> $elfCalories[$b] } 1 .. $elf;
say "SORT: $sorted[-1] $elfCalories[ $sorted[-1] ]";


say "TOP 3: ", sum( @elves[ @sorted[-3..-1]);

