# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Chamber.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Chamber;

use v5.36;
use lib ".";

use Moo;
use List::Util qw/first/;
use Bits;


has highest => ( is => 'rw', default => 0 );
has width   => ( is => 'ro', default => 7 );
has stack   => ( is => 'rw', default => sub { [ 0b1111111 ] } );

has currentPiece => ( is => 'rw', default => undef );
has pieceBottom  => ( is => 'rw', default => 0 );
has pieceMask    => ( is => 'rw', default => 0b1111111 );
has leftGap      => ( is => 'rw', default => 0 );
has rightGap     => ( is => 'rw', default => 0 );

my $StackWidthMask = 0x7f;

my @ColumnMask = ( 0b0000001,
                   0b0000010,
                   0b0000100,
                   0b0001000,
                   0b0010000,
                   0b0100000,
                   0b1000000,
                  );

sub _trim($self)
{
    pop $self->stack->@* while $self->stack->[-1] == 0;
}

sub getHeight($self)
{
    # Remove any blank rows from the end of the 
    $self->_trim();
    # Don't include the base row
    return scalar($self->stack->@*) - 1;
}

sub getTopRow($self)
{
    $self->_trim();
    return $self->stack->[-1];
}

# Shift the set of top rows into a long integer.  The
# state of the stack is the set of open positions down
# to the first row where all columns are blocked, but
# the top few rows are a good-enough approximation.
sub getState($self)
{
    my ($row, $shift) = (-1, 0);
    my $state;
    my $limit = scalar($self->stack->@*);
    $limit = ( $limit < 6 ? -$limit : -5 );
    for ($row = -1, $shift = 0; $row >= $limit; $row--, $shift += 8 )
    {
        $state |= ($self->stack->[$row] << $shift);
    }
    return $state;
}

sub _stringify($self, $bitmap)
{
    my $s = sprintf("%0$self->{width}b", $bitmap);
    $s =~ tr/01/.#/;
    return $s;
}
sub show($self)
{ 
    my $s;
    my $top = scalar($self->stack->@*) - 1;
    for ( my $row = $top; $row >= 0; $row-- )
    {
        my $r = $self->_stringify( $self->stack->[$row] );
        if ( $row == $top )
        {
            $s = sprintf "%5d | %s |", $top, $r;
        }
        else
        {
            $s .= sprintf "      | %s |", $r;
        }
        if ( $row == $self->pieceBottom )
        {
            $s .= sprintf " pieceBottom left=%d right=%d", $self->leftGap, $self->rightGap
        }
        print "$s\n";
        $s = "";
    }
}

# Grow the stack by the height of the new piece and place it on top.
sub dropPiece($self, $piece)
{
    my $leftGap = 2;
    my $rightGap = $self->{width} - $leftGap - $piece->{width};

    my @newRow = map { $_ << $rightGap } $piece->{shape}->@*;
    $self->pieceMask( $self->pieceMask << $rightGap );

    # Make three blank rows at the top of the stack before we drop the piece
    $self->_trim();
    push $self->stack->@*, 0 for 1..3;
    push $self->stack->@*, reverse(@newRow);

    my $top = scalar($self->stack->@*) -1 ;
    $self->pieceBottom($top - $piece->height + 1);
    $self->leftGap($leftGap);
    $self->rightGap($rightGap);
    $self->currentPiece($piece);
    # say "Pushed piece ", $piece->id, " stack is now ", $top;

}

sub _bitColumn($col, $list)
{
    return [ map { ($_ & $ColumnMask[$col]) >> $col } @$list ];
}

sub _arrAnd($a1, $a2)
{
    return 0 if scalar(@$a1) != scalar(@$a2);
    for ( my $i = 0 ; $i < scalar(@$a1) ; $i++ )
    {
        return 1 if ( $a1->[$i] && $a2->[$i] );
    }
    return 0;
}

sub doJet($self, $jet)
{
    my $p = $self->currentPiece;
    my $pBottom = $self->pieceBottom;
    my $pTop = $pBottom + $p->height - 1;
    if ( $jet eq "<" && $self->leftGap > 0 )
    {
        my @pRow = $self->stack->@[$pBottom..$pTop];

        my $src = $p->asBitMask($self->rightGap);
        my $dst = $p->asBitMask($self->rightGap + 1);

        Bits::erase(\@pRow, $src);

        if ( not Bits::hasOverlap(\@pRow, $dst) )
        {
            $self->{leftGap}--; $self->{rightGap}++;
            $self->{pieceMask} <<= 1;
            Bits::place(\@pRow, $dst);
            $self->stack->[$pBottom + $_] = $pRow[$_] for 0 .. ($pTop - $pBottom );
        }
    }
    elsif ( $jet eq ">" && $self->rightGap > 0 )
    {
        my @pRow = $self->stack->@[$pBottom..$pTop];

        my $src = $p->asBitMask($self->rightGap);
        my $dst = $p->asBitMask($self->rightGap - 1);

        Bits::erase(\@pRow, $src);

        if ( not Bits::hasOverlap(\@pRow, $dst) )
        {
            $self->{leftGap}++; $self->{rightGap}--;
            $self->{pieceMask} >>= 1;
            Bits::place(\@pRow, $dst);
            $self->stack->[$pBottom + $_] = $pRow[$_] for 0 .. ($pTop - $pBottom );
        }
    }
}

sub fall($self)
{
    my $p = $self->currentPiece;
    my $pBottom = $self->pieceBottom;
    my $pTop    = $pBottom + $p->height -1;
    my $mask = $p->mask << $self->rightGap;
    my $s = $self->stack;
    my $h = $p->height;

    # pRows is a bitMap of rows containing the piece. Mask out other rocks.
    my @pRows = $self->stack->@[$pBottom..$pTop];
    for ( my $r = $h-1; $r >= 0 ; $r-- )
    {
        my $prock = ($p->shape->[$h - $r -1] << $self->rightGap);
        $pRows[$r] = $pRows[$r] & $mask & $prock;
    }

    # into is a bitmap of rows of chamber rocks.  Mask out the piece.
    my @into  = $self->stack->@[ ($pBottom-1) .. ($pTop-1) ];
    for ( my $r = 1 ; $r < $h ; $r++ )
    {
        my $prock = ($p->shape->[$h - $r] << $self->rightGap);
        $into[$r] = $into[$r] & ~$prock & $StackWidthMask;
    }

    # Now see if the pRows overlays into 
    my $blocked = 0;
    for ( my $r = 0 ; $r < $h && $blocked == 0 ; $r++ )
    {
        $blocked |= ( $pRows[$r] & $into[$r] );
    }

    return 0 if ( $blocked ); # Everything stays the same, but fall fails

    # Erase the piece from its current position in the stack
    for ( my $r = 0 ; $r < $h ; $r++ )
    {
       $s->[$pBottom + $r] = ($s->[$pBottom+$r] & ~$pRows[$r]) & $StackWidthMask;
    }

    # Insert the piece into its new position one row lower.
    for ( my $r = 0 ; $r < $h ; $r++ )
    {
        $s->[$pBottom + $r - 1] |= $pRows[$r];
    }
    $self->pieceBottom( $self->pieceBottom -1 );

    return 1;
}
1;
