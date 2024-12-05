# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Node.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Node;
use v5.36;

use Moo;

has id => ( is => 'ro', required => 1 );
has value => ( is => 'rw', default => undef );

sub hasValue($self)
{
    return defined $self->value;
}

package Variable;
use v5.36;

use Moo;
extends 'Node';

sub clear($self)
{
    # Do nothing, these are constants
}

sub showTree($self, $depth)
{
    say "", (' 'x$depth), "VAR: ", $self->id, "=", $self->value;
}

sub eval($self, $indent="")
{
    say $indent, "EVAL VAR ", $self->id, "=", ($self->value//"undef");
    return $self->value;
}

sub solve($self, $target, $indent="")
{
    if ( $self->hasValue )
    {
        if ( $self->value != $target )
        {
            die "Variable ".$self->id."=".$self->value." but target=$target";
        }
    }
    else
    {
        say $indent, "Solve: ", $self->id, "=$target";
        $self->value($target);
    }
}


package Expression;
use v5.36;
use Moo;
extends 'Node';

use lib ".";
use SymbolTable;

has op     => ( is => 'ro', required => 1 );
has left   => ( is => 'rw', required => 1 );
has right  => ( is => 'ro', required => 1 );

my %OP = (
    '+' => sub($l, $r) { $l + $r },
    '-' => sub($l, $r) { $l - $r },
    '*' => sub($l, $r) { $l * $r },
    '/' => sub($l, $r) { $l / $r },
);

sub getOperands($self)
{
    my $sym = SymbolTable->instance();
    my $left  = $sym->lookup($self->left);
    my $right = $sym->lookup($self->right);

    return ($left, $right);
}

sub showEquation($self)
{
    my ($left, $right) = $self->getOperands();
    my $lval = $left->value // "undef";
    my $rval = $right->value // "undef";
    my $val  = $self->value // "undef";

    $self->id. "($val)=". $self->left."($lval)". $self->op. $self->right. "($rval)";
}

sub showTree($self, $depth=2)
{
    my ($left, $right) = $self->getOperands();
    say "", (" "x$depth), $self->showEquation();
    if ( --$depth )
    {
        $left->showTree($depth);
        $right->showTree($depth);
    }
}


sub clear($self)
{
    $self->value(undef);
    my ($left, $right) = $self->getOperands();
    $left->clear();
    $right->clear();
}

sub eval($self, $indent="")
{
    say  $indent, "EVAL EXPR ", $self->showEquation;
    return $self->value if $self->hasValue;

    my ($left, $right) = $self->getOperands();

    my $lval = $left->eval(" $indent");
    my $rval = $right->eval(" $indent");
    if ( ! ( defined $lval && defined $rval) )
    {
        $self->value(undef);
        return undef;
    }

    $self->value( $OP{$self->op}->($lval, $rval) );
    #if    ( $self->op eq '+' ) { $self->value ( $lval + $rval ) }
    #elsif ( $self->op eq '-' ) { $self->value ( $lval - $rval ) }
    #elsif ( $self->op eq '*' ) { $self->value ( $lval * $rval ) }
    #elsif ( $self->op eq '/' ) { $self->value ( $lval / $rval ) }
    say  $indent, "EVAL RSLT ", $self->showEquation;
    return $self->value;
}

sub solve($self, $target, $indent="")
{
    my ($left, $right) = $self->getOperands();

    my $lval = $left->eval(" $indent");
    my $rval = $right->eval(" $indent");

    say $indent, "solve t=$target ", $self->showEquation();

    my $op = $self->op;
    if ( (defined $lval) && (!defined $rval) )
    {
        if    ( $op eq '+' ) { $rval = $target - $lval }
        elsif ( $op eq '-' ) { $rval = $target + $lval }
        elsif ( $op eq '*' ) { $rval = $target / $lval }
        elsif ( $op eq '/' ) { $rval = $lval / $target }

        $right->solve($rval, " $indent");
    }
    elsif ( (!defined $lval) && (defined $rval) )
    {
        if    ( $op eq '+' ) { $lval = $target - $rval }
        elsif ( $op eq '-' ) { $lval = $target + $rval }
        elsif ( $op eq '*' ) { $lval = $target / $rval }
        elsif ( $op eq '/' ) { $lval = $rval * $target }

        $left->solve($lval, " $indent");
    }
    elsif ( (!defined $lval) && (!defined $rval) )
    {
        die "Can't solve for $target at ", $self->id;
    }
    else
    {
        if ( $self->value != $target )
        {
            die "Inconsistent: ". $self->id.
            " has lval=$lval".$self->op."rval=$rval but target=$target and val=". $self->value;
        }
    }

    # Check for overflow and rounding errors.
    my $got = $OP{$self->op}->($left->value, $right->value);
    if ( $got != $target )
    {
        my $msg = "Math error expected $target, got $got at ". $self->showEquation;
        #die $msg;
    }
    $self->value($got);
    say "$indent solved ", $self->showEquation;
}

1;
