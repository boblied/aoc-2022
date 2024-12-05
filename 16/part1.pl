#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use List::Util qw/any/;

use Data::Dumper;
{ no warnings "once"; $Data::Dumper::Sortkeys=1; }

my %Cave;
my @ValveNumToName;

my $Clock = 30;

my $MaxFlow = 0;

readInput();


sub readInput()
{
    my $valveId = 0;
    while (<>)
    {
        chomp;
        my ($valve, $flow, $tunnel) = ($_ =~
m/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)$/ );
        my @tunnel = split(", ", $tunnel);

        say "$valve, $flow, [@tunnel]";

        push @ValveNumToName, $valve;
        $Cave{$valve} = { flow => $flow,
                          tunnel => [ @tunnel ],
                          id => $#ValveNumToName,
                        };
    }
}

sub maxFlow($valveId, $clock)
{
    my $flow = 0;
    while ( $clock > 0 )
    {
        my $next  = best($valveId, $clock, {});
        $valveId  = $next->[0];
        $flow    += $next->[1];
        $clock    = $next->[2];
    }
    say "MAXFLOW=$flow";
    return $flow;
}

sub best($valveId, $clock, $valveIdList)
{
    say "FIND BEST FROM $valveId at $clock";
    my $rank = List::PriorityQueue->new();
    findScore($valveId, $clock, $rank, {}, "" );
    my $best = $rank->pop();
    say "FROM $valveId, best=[$best->@*]";

    return ($best->@*); # ID, score, clock
}

sub findScore($valveId, $clock, $rank, $seen, $indent )
{
    if ( $clock == 0 || (exists $seen->{$valveId}) )
    {
        say $indent, "DONE AT clock=$clock and valve=$valveId";
        return;
    }

    my $valve = $Cave{$valveId};
    say $indent, "Clock=$clock ARRIVE at $valveId";

    if ( $valve->{flow} != 0 )
    {
        $clock--; # Cost of opening the valve
        my $flow = $valve->{flow} * ($clock-1);
        $rank->insert( [ $valveId, $flow, $clock ], -$flow); # Lowest priority pops first
        say $indent, "Clock=$clock INSERT $valveId => $flow";
    }
    $seen->{$valveId}++; # Mark as processed

    for my $t ( $valve->{tunnel}->@* )
    {
        next if exists $seen->{$t};
        say $indent, "Clock=$clock valve=$valveId MOVE TO $t";

        findScore($t, $clock-1, $rank, { $seen->%* }, "  $indent" );
    }
}

my @Adj;
my @M;
sub adjMatrix()
{
    my $n = $#ValveNumToName;;

    for my $row ( 0 .. $n )
    {
        push @Adj, [ (0) x ($n+1) ];
    }

    for my $from ( 0 .. $n )
    {
        my $fromV = $Cave{ $ValveNumToName[$from] };

        for my $to ( $fromV->{tunnel}->@* )
        {
            $Adj[ $from ][ $Cave{$to}{id} ] = 1;
            $Adj[ $Cave{$to}{id} ][ $from ] = 1;
        }
    }

    # Warshall algorithm for pair-wise distances
    
    for my $row ( 0 .. $n )
    {
        push @M, [ (999) x ($n+1) ];
    }
    for my $row ( 0 .. $n )
    {
        for my $col ( 0 .. $n )
        {
            if ( $Adj[$row][$col] )
            {
                $M[$row][$col] = $Adj[$row][$col];
            }
            else
            {
                $M[$row][$col] = ( $row != $col ) ? 9999 : 0;
            }
        }
    }

    for my $k ( 0 .. $n )
    {
        for my $i ( 0 .. $n )
        {
            for my $j ( 0 .. $n )
            {
                if ( $M[$i][$j] > $M[$i][$k] + $M[$k][$j] )
                {
                    $M[$i][$j] = $M[$i][$k] + $M[$k][$j]
                }
            }
        }
    }

    # If a valve has no flow, skip over it.  Any tunnel leading into
    # a 0 valve can be replaced with a tunnel to the outgoing side of it.
    # Update the distance between the nodes, then remove the no-flow node.

    for my $zeroName ( grep { $Cave{$_}{flow} == 0 } keys %Cave )
    {
        my $zeroNum = $Cave{$zeroName}{id};
        my $zeroV = $Cave{$zeroName};

        for my $fromNum ( 0 .. $n)
        {
            next unless ( $Adj[$fromNum][$zeroNum] );

            my $fromName = $ValveNumToName[$fromNum];
            my $fromV = $Cave{$fromName};

            say "Pruning from $fromName ($fromNum) to $zeroName ($zeroNum)";

            # Remove the edge
            say "  Remove edge [$fromNum][$zeroNum] and [$zeroNum][$fromNum]";
            $Adj[$fromNum][$zeroNum] = $Adj[$zeroNum][$fromNum] = 0;
            $zeroV->{tunnel} = [ grep { $_ ne $fromName} $zeroV->{tunnel}->@* ];
            $fromV->{tunnel} = [ grep { $_ ne $zeroName} $fromV->{tunnel}->@* ];

            # Add edge to skip over zero to zero's destinations
            for my $toName ( $zeroV->{tunnel}->@* )
            {
                next if $toName eq $fromName;
                my $toV   = $Cave{$toName};
                my $toNum = $Cave{$toName}{id};

                say "  Routing to $toName ($toNum)";

                # Remove the edge
                #say "  Remove edge [$toNum][$zeroNum] and [$zeroNum][$toNum]";
                #$Adj[$toNum][$zeroNum] = $Adj[$zeroNum][$toNum] = 0;

                # This edge now exists
                say "  Add edge [$fromNum][$toNum] and [$toNum][$fromNum]";
                $Adj[$fromNum][$toNum] = $Adj[$toNum][$fromNum] = 1;
                push @{$fromV->{tunnel}}, $toName;
                push @{$toV->{tunnel}}  , $fromName;

                # Update minimum distance array.
                my $newDist = $M[$fromNum][$zeroNum] + $M[$zeroNum][$toNum];
                my $oldDist = $M[$fromNum][$toNum];
                $M[$fromNum][$toNum] = $newDist if $newDist < $oldDist;
                $M[$toNum][$fromNum] = $M[$fromNum][$toNum]; # symmetry

                say " M [$toNum][$fromNum] = $M[$fromNum][$toNum]";
            }
        }
    }
    return;
}

sub showMatrix($m)
{
    my $height = scalar $m->@*;;
    my $width  = scalar $m->[0]->@*;

    print "    "; printf("%3d", $_) for 0 .. ($width-1); print "\n";
    for my $row ( 0 .. ($height-1) )
    {
        printf("%4d", $row);
        printf("%3d", $m->[$row][$_]) for 0 .. ($width-1);
        print "\n";
    }
}

# Before pruning the graph, establish start points in case we prune the entry
my @Start;
@Start = findStart('AA', \@Start, []);

sub findStart($s, $start, $seen)
{
    push @$seen, $s;
    if ( $Cave{$s}{flow} != 0 )
    {
        push @$start, $s;
        return;
    }
    for my $t ( $Cave{$s}{tunnel}->@* )
    {
        findStart($t, $start, $seen) unless any { $_ eq $t } $seen->@*;
    }

    return ( $start->@* );
}
adjMatrix();
say "DONE";
