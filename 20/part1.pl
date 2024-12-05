#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use File::Slurper qw/read_lines/;

sub show($m, $hdr=1)
{
    my $len = scalar(@$m);
    return if $len > 40;
    if ( $hdr ) { printf("%3d ", $_) for ( 0 .. $len-1 ); print "\n" };
    printf("%3d ", $_) for $m->@*; print "\n";
}

my @MessageInput;
my @Message;
for ( @ARGV )
{
    @MessageInput = map { $_+0 } read_lines($_);
}
@Message = @MessageInput;
my $MsgLen = scalar(@MessageInput);

# Example:
# Initial condition
#              index  0   1   2   3   4   5   6
# MessageInput value  1   2  -3   3  -2   0   4
#      Message        1   2  -3   3  -2   0   4
#
#         i2m         0   1   2   3   4   5   6
#         m2i         0   1   2   3   4   5   6

# Location of the i'th number in the message output.
# Given index i, maps MessageInput[i] to a location in Message
# i2m says "I have the i'th number. Give me the index of
# the ith number in Message"
my @i2m = ( 0 .. $#MessageInput );

# Inverse of i2m.  Map a value in Message back to where it
# started in Message Input.
# m2i says "I have the m'th position in Message.  Give me
# the index in MessageInput where it came from"
my @m2i = ( 0 .. $#Message );

# The rotation is as if the number were picked out of the row
# and then counts off.  This effectively makes it module (length-1)
# instead of modulo(length).
#
# That also makes a difference in whether it moves positive or
# negative.  A positive move wraps around back into position 0,
# but a negative move wraps around into positiion length-1.

mix();

# Find the location of the first 0

my $indexOfZero;
for ( $indexOfZero = 0 ; $indexOfZero < $MsgLen; ++$indexOfZero )
{
    if ( $MessageInput[ $m2i[$indexOfZero] ] == 0 )
    {
        last;
    }
}
my $num1 = $MessageInput[ $m2i[ ($indexOfZero + 1000) % $MsgLen ] ];
my $num2 = $MessageInput[ $m2i[ ($indexOfZero + 2000) % $MsgLen ] ];
my $num3 = $MessageInput[ $m2i[ ($indexOfZero + 3000) % $MsgLen ] ];

say "Zero is at $indexOfZero, numbers are $num1, $num2, $num3";
say "Grove coordinate is: ", $num1 + $num2 + $num3;


if ( @Message > 10 )
{
    say "HEAD:  @MessageInput[0..9]";
    say "Tail  @MessageInput[-10..-1]";
}
else
{
    say "IN:  @MessageInput";
    say "OUT: @Message";
}

sub mix()
{
    for ( my $i = 0; $i < $MsgLen ; $i++ )
    {
        mixOne($i % $MsgLen );
    }
}

sub mixOne($i)
{
    my $val = $MessageInput[$i];
    my $beg = $i2m[$i];

    my $end;
    if ( $val > 0 )
    {
        $end  = ($beg + $val) % ($MsgLen-1);
    }
    elsif ( $val < 0 )
    {
        $end = ($beg + $val%($MsgLen-1)) % $MsgLen;
    }
    else
    {
        say "i=$i val=$val (no-op)";
        return;
    }

    # Rotate the range of digits in the output message.
    if ( $beg < $end )
    {
        rLeftIn( \@m2i, $beg, $end);
    }
    else
    {
        ($beg, $end) = ($end, $beg);
        rRightIn( \@m2i, $beg, $end);
    }

    say "i=$i val=$val beg=$beg end=$end";

    # Record where the i'th number moved to
    for my $j ( $beg .. $end )
    {
        $i2m[ $m2i[$j] ] = $j;
        # Don't really need to keep the output message,
        # but useful for  debugging.
        $Message[$j] = $MessageInput[ $m2i[$j] ];
    }

     show(\@Message);
}

sub rLeftIn($arr, $beg, $end)
{
    my $rot = $arr->[$beg];
    for ( my $j = $beg ; $j < $end ; $j++ )
    {
        $arr->[$j] = $arr->[$j+1];
    }
    $arr->[$end] = $rot;
}
sub rRightIn($arr, $beg, $end, $n=1)
{
    my $rot = $arr->[$end];
    for ( my $j = $end ; $j > $beg ; $j-- )
    {
        $arr->[$j] = $arr->[$j-1];
    }
    $arr->[$beg] = $rot;
}
