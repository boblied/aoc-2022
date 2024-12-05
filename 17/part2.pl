#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part2.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use Log::Log4perl qw(:easy);
use Getopt::Long;

use lib ".";
use Chamber;
use Piece;

my $logger = Log::Log4perl->get_logger();
Log::Log4perl->easy_init($INFO);
$logger->info("START");

my $DoDebug = 0;
GetOptions("debug" => \$DoDebug);
$logger->level($DEBUG) if $DoDebug;


my $PieceCount = 0;
my $MaxPiece = 2022;

my @Jet;

while ( (<>) )
{
    chomp;
    push @Jet, split '';
}

say "Number of jets: ", scalar @Jet;

my $c = Chamber->new();

my $FallCount = 0;

my $JetSize = scalar(@Jet); # ~10,000
my $JetCount = 0;

my @State; # [piece][jetno] => { stackState, height, piececount}

my @PieceHistory; # Height after each piece is in place 

my $GoalPieces = 1e12;

while ( $PieceCount++ < 10000 )
{
    my $p = Piece::next();


    my $cState = $c->getState;
    my $cHeight = $c->getHeight;
    if ( not exists $State[$p->id][$JetCount] )
    {
        $State[$p->id][$JetCount] = { stack => $cState, height => $cHeight, pcount => $PieceCount };
        $logger->debug( sprintf("STATE %3d add [%2d][%2d] = { ", $PieceCount, $p->id,$JetCount),
            sprintf("stack=%014x height=%3d pcount=%3d", $cState, $cHeight, $PieceCount) );
    }
    elsif ( $State[$p->id][$JetCount]->{stack} == $cState )
    {
        my $prevH = $State[$p->id][$JetCount]->{height};
        my $prevP = $State[$p->id][$JetCount]->{pcount};
        $logger->info("Cycle before p=$PieceCount j=$JetCount, top=", sprintf("%014x", $cState),
            " h=$cHeight, prevH=$prevH  prevP=$prevP",
            " dH=", $cHeight-$prevH, " dP=", $PieceCount-$prevP);

        exit calcFromCycle( $State[$p->id][$JetCount], \@PieceHistory, $PieceCount-1, $cHeight );
    }
    else
    {
        $logger->debug(sprintf("Not a cycle at p=$PieceCount j=$JetCount, cstate=%x, h=$cHeight", $cState));
    }


    #say "Drop #$PieceCount: $p->{id} Jet=$JetCount Fall=$FallCount";
    $c->dropPiece($p);
    # $c->show();
    my $canFall = 1;
    while ( $canFall )
    {
        my $j = shift @Jet;
        push @Jet, $j; # List repeats forever
        $JetCount = ($JetCount + 1) % $JetSize;
        $logger->info("Jet cycle reached at piece $PieceCount") if $JetCount == 0;
        $logger->debug("Jet $JetCount: $j");

        $c->doJet($j);

        $canFall = $c->fall();
        $FallCount++;
        $logger->debug("Fall: ", $canFall);
    }
    push @PieceHistory, $c->getHeight;
}

sub calcFromCycle($state, $pHistory, $pcount, $height)
{
    my ($prevP, $nowP) = ($state->{pcount}, $pcount);
    my ($prevH, $nowH) = ($state->{height}, $height);

    my $heightPerCycle = ($nowH - $prevH);
    my $piecesPerCycle  = ($nowP - $prevP + 1);

    $logger->info("Cycle: height=$heightPerCycle, pieces=$piecesPerCycle");

    my $target = $GoalPieces - $pcount;

    my $cyclesToTarget = int($target / $piecesPerCycle); #undershoot
    my $remainder = $GoalPieces - ($cyclesToTarget * $piecesPerCycle + $pcount);
    $logger->info("Remainder=$remainder pieces");
    my $finalHeight = $height + ( $cyclesToTarget * $heightPerCycle);

    # For the remainder pieces, refer to the history to see how much
    # each piece of the cycle adds to the height.
    my $p = $pcount - $piecesPerCycle;
    my $cycleBaseHeight = $pHistory->[$p];
    my $remainderHeight = $pHistory->[$p+$remainder+1] - $cycleBaseHeight;
    $finalHeight += $remainderHeight;

    if ( $logger->is_debug )
    {
        for my $x ( ($p-5) .. ($p+5) )
        {
            $logger->debug("base History [$x] = $pHistory->[$x]");
        }
        for my $x ( ($p+$remainder-5) .. ($p+$remainder+5) )
        {
            $logger->debug("remainder History [$x] = $pHistory->[$x]");
        }
    }

    say "Cycles to target: $cyclesToTarget, finalHeight=$finalHeight";
}

say $c->getHeight();
