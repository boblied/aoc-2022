#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

$/ = \1;

my $marker = "";
my $position = 0;
while (<>)
{
    $position++;
    my $char = $_;

    while ( $marker =~ /$_/ )
    {
        $marker = substr($marker, 1);
    }
    $marker .= $char;

    last if ( length($marker) == 14);
}

say "$position, $marker";
