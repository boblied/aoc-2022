#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Data::Dumper;
use List::Util qw/zip/;
use Scalar::Util qw/reftype/;

my $p = 0;
my @pair;

my $indexSum = 0;

$/ = ""; # Paragraph at a time
while (<>)
{
    chomp;
    my @pair = split "\n";
    say "$pair[0]    $pair[1]";
    $p++;

    eval "\$pair[0] = $pair[0]";
    eval "\$pair[1] = $pair[1]";

    if ( compare(@pair, "") eq 'YES' )
    {
        say "INORDER: $p YES";
        $indexSum += $p;
    }
    else
    {
        say "INORDER: $p NO";
    }
}

say "INDEX SUM: $indexSum";

#say "INORDER= ",compare( [1, 1,5,1,1], [1,1,3,1,1] , "");

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

sub compare($p1, $p2, $indent)
{
    my $inOrder = 'TBD';
    foreach ( zip $p1, $p2 )
    {
        my ($left, $right) = @$_;
        my ($rleft, $rright) = ( reftype($left), reftype($right) );
        say "${indent}LEFT=", show($left), " RIGHT=", show($right);

        if ( not defined $left )
        {
            # Ran out of p1 before p2, OK
            return 'YES';
        }
        elsif ( not defined $right )
        {
            # Ran out of p2 before p1
            return 'NO';
        }

        if ( not defined $rleft ) # Scalar
        {
            if ( not defined $rright ) # Also scalar
            {
                my $cmp = $left <=> $right;
                return 'YES' if $cmp < 0;
                return 'NO'  if $cmp > 0;
                # else continue checking
            }
            else
            {
                # Put scalar into list for comparison
                $inOrder = compare( [ $left ], $right, "  $indent");
            }
        }
        elsif ( not defined $rright )
        {
            $inOrder = compare( $left, [ $right ], "  $indent");
        }
        else # array vs. array
        {
            $inOrder = compare($left, $right, "  $indent");
        }

        return $inOrder if $inOrder ne 'TBD';
    }

    return $inOrder;
}
