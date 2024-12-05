#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:

use v5.36;
use lib ".";

use Data::Dumper;

use Piece;
use Bits;

my @background = ( (0b1100001) x 3 );

my $p = Piece::makePiece(2);

my $bm = $p->asBitMask(0);

say "Piece:";
showBitMask($bm);

say "Background before place";
say "Overlap? ", hasOverlap(\@background, $bm);
showBitMask(\@background);

Bits::place(\@background, $bm);
say "Background after place";
say "Overlap? ", hasOverlap(\@background, $bm);
showBitMask(\@background);

Bits::erase(\@background, $bm);
say "Background after erase";
say "Overlap? ", hasOverlap(\@background, $bm);
showBitMask(\@background);
