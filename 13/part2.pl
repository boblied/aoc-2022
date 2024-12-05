#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Data::Dumper;
use List::Util qw/sum/;
use Scalar::Util qw/reftype/;

my $p = 0;


my @packetList;

while (<>)
{
    chomp;
    next if /^$/;

    # Turn all empty lists into a list containing 0
    # because flatten takes them out completely
    s/\[\]/[0]/g;

    $p++;
    my $plist;
    eval "\$plist = $_";
    push @packetList, $plist;
}

sub flatten # No signature on purpose
{
    return map { ref eq 'ARRAY' ? flatten(@$_) : $_ } @_;
}

my @flat;

for my $p (@packetList)
{
    my @f = flatten($p);
    push @flat, [ @f ];
}

# Count the frequency of first digits
my @freq = (0) x 10;
for my $f ( @flat )
{
    if ( @$f == 0 ) { $freq[0]++ }
    else { $freq[$f->[0]]++ }
}

my $indexOf2 = sum( @freq[0..1] ) + 1;
my $indexOf6 = sum( @freq[0..5] ) + 2;
my $indexProd = $indexOf2 * $indexOf6;
say "INDEX SUM: 2 at $indexOf2, 6 at $indexOf6, product = $indexProd";


sub show($p)
{
    my $str = "";
    my $rt = reftype($p);
    if ( not defined $p )
    {
        return "undef";
    }
    if ( not defined $rt )
    {
        return $p;
    }
    elsif ( $rt eq 'ARRAY' )
    {
        return "[", join(",", $p->@*), "]";
    }
    else
    {
        say "Unexpected reftype($p) = $rt";
        return $p;
    }
}
