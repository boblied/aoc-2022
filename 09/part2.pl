#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;
use Carp qw/croak confess/;
use List::MoreUtils qw/minmax/;

use lib "lib";
use Node;

my $KNOT = 10;

my @Rope;
$Rope[$_] = Node->new for 0 .. ($KNOT-1);
my $Head = $Rope[0];
my $Tail = $Rope[-1];

my @Path = ( [ 0, 0 ] );
my %Seen = ( 0 => { 0 => 1 } );

sub dumpPath($p)
{
    my ($xmin, $xmax) = minmax( map { $_->[0] } @$p );
    my ($ymin, $ymax) = minmax( map { $_->[1] } @$p );

    for ( my $y = $ymax ; $y >= $ymin ; $y-- )
    {
        for ( my $x = $xmin; $x <= $xmax ; $x++ )
        {
            my $s = $Seen{$x}{$y} ? '#' : ".";
            print "$s";
        }
        print ".\n";
    }

    say "x=[$xmin-$xmax] y=[$ymin, $ymax]";
}

sub dragRope($rope)
{
    $rope->[$_]->moveToward( $rope->[$_-1] ) for ( 1 .. scalar(@$rope)-1 );
    return $rope->[-1]->coord();
}

while (<>)
{
    chomp;
    my ($direction, $distance) = split;

    if ( $direction eq "R" )
    {
        while ( $distance-- )
        {
            $Head->moveRight;
            my ($x, $y) = dragRope(\@Rope);
            push @Path, [ $x, $y ] unless $Seen{$x}{$y}++;
        }
    }
    elsif ( $direction eq "L" )
    {
        while ( $distance-- )
        {
            $Head->moveLeft;
            my ($x, $y) = dragRope(\@Rope);
            push @Path, [ $x, $y ] unless $Seen{$x}{$y}++;
        }
    }
    elsif ( $direction eq "U" )
    {
        while ( $distance-- )
        {
            $Head->moveUp;
            my ($x, $y) = dragRope(\@Rope);
            push @Path, [ $x, $y ] unless $Seen{$x}{$y}++;
        }
    }
    elsif ( $direction eq "D" )
    {
        while ( $distance-- )
        {
            $Head->moveDown;
            my ($x, $y) = dragRope(\@Rope);
            push @Path, [ $x, $y ] unless $Seen{$x}{$y}++;
        }
    }
}

dumpPath(\@Path);
say "COUNT: ", scalar(@Path);

