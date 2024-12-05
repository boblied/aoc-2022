# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Piece.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Piece;

use v5.36;
use lib ".";

use Moo;

use Bits;

has height    => ( is => 'ro', required => 1 );
has width     => ( is => 'ro', required => 1 );
has shape     => ( is => 'ro', required => 1 );
has id        => ( is => 'ro', required => 1 );
has mask      => ( is => 'ro', required => 1 );
has leftEdge  => ( is => 'ro', required => 1 );
has rightEdge => ( is => 'ro', required => 1 );

my @PieceType = (
    {   height => 1, width => 4, mask => 0b1111,
        shape => [  0b1111, ],
        leftEdge => 0b1, rightEdge => 0b1,
    },
    {   height => 3, width => 3, mask => 0b111,
        shape  => [ 0b010, 0b111, 0b010 ],
        leftEdge => 0b010, rightEdge => 0b010,
    },
    {   height => 3, width => 3, mask => 0b111,
        shape => [  0b001, 0b001, 0b111 ],
        leftEdge => 0b001, rightEdge => 0b111,
    },
    {   height => 4, width => 1, mask => 0b1,
        shape => [  0b1, 0b1, 0b1, 0b1 ],
        leftEdge => 0b1111, rightEdge => 0b1111,
    },
    {   height => 2, width => 2, mask => 0b11,
        shape => [  0b11, 0b11 ],
        leftEdge => 0b11, rightEdge => 0b11,
    }
);

my $nextPiece = 0;

sub next()
{
    my $p = makePiece($nextPiece);
    $nextPiece = ($nextPiece + 1) % scalar(@PieceType);
    return $p;
}

sub makePiece($num)
{
    my $p = $PieceType[$num];
    return Piece->new( id => $num,
                     height => $p->{height}, width => $p->{width},
                     shape => $p->{shape}, mask => $p->{mask},
                     leftEdge => $p->{leftEdge}, rightEdge => $p->{rightEdge}
                 );
}

sub show($self)
{
    say "Piece $self->{id}: $self->{height} X $self->{width}:";
    for my $row ( $self->shape->@* )
    {
        say $self->_stringify($row);
    }
}

sub _stringify($self, $bitmap)
{
    return Bits::stringify($bitmap, $self->width);
}

sub asBitMask($self, $rightGap = 0)
{
    return Bits::bitmask($self->shape, $rightGap);
}

1;
