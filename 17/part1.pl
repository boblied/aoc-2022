#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use lib ".";
use Chamber;
use Piece;

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
my $JetCount = 0;
while ( $PieceCount++ < 2022 )
{
    my $p = Piece::next();

    say "Drop #$PieceCount: $p->{id} Jet=$JetCount Fall=$FallCount";
    $c->dropPiece($p);
    $c->show();
    my $canFall = 1;
    while ( $canFall )
    {
        my $j = shift @Jet;
        push @Jet, $j; # List repeats forever
        $JetCount++;
        say "Jet $JetCount: $j";
        $c->doJet($j);

        $canFall = $c->fall();
        $FallCount++;
        say "Fall: ", $canFall;
    }
}

say $c->getHeight();
