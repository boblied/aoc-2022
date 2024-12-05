# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Bits.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Bits;

use v5.36;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(stringify bitmask showBitMask hasOverlap);
our @EXPORT_OK = qw();

sub stringify($bitmap, $width)
{
    my $s = sprintf("%0${width}b", $bitmap);
    $s =~ tr/01/.#/;
    return $s;
}

sub bitmask($shape, $rightGap = 0)
{
    return [ map { $_ << $rightGap  } reverse $shape->@* ];
}

sub bitmaskNot($shape, $rightGap = 0)
{
    return [ map { ~($_ << $rightGap) & 0x7f } reverse $shape->@* ];
}

sub showBitMask($bm)
{
    for ( my $r = (scalar(@$bm)-1) ; $r >= 0 ; $r-- )
    {
        say "BM $r ", stringify($bm->@[$r], 7)
    }
}

sub place($background, $thing)
{
    for my $row ( 0 .. (scalar($background->@*)-1) )
    {
        $background->@[$row] |= $thing->@[$row];
    }
}

sub erase($background, $thing)
{
    for my $row ( 0 .. (scalar($background->@*)-1) )
    {
        $background->@[$row] &= (~$thing->@[$row] & 0x7f);
    }
}

sub hasOverlap($background, $thing)
{
    for my $row ( 0 .. (scalar($background->@*)-1) )
    {
        return 1 if ( $background->@[$row] & $thing->@[$row] )
    }
    return 0;
}


1;

