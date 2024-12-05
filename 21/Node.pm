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
use Moo;
extends 'Node';

sub eval($self)
{
    return $self->value;
}


package Expression;
use Moo;
extends 'Node';

use lib ".";
use SymbolTable;

has op     => ( is => 'ro', required => 1 );
has left   => ( is => 'rw', required => 1 );
has right  => ( is => 'ro', required => 1 );

sub getOperands($self)
{
    my $sym = SymbolTable->instance();
    my $left  = $sym->lookup($self->left);
    my $right = $sym->lookup($self->right);

    return ($left, $right);
}

sub sayEquation($self)
{
    my ($left, $right) = $self->getOperands();
    my $lval = $left->value // "undef";
    my $rval = $right->value // "undef";
    my $val  = $self->value // "undef";

    $self->id. "($val)=". $self->left."($lval)". $self->op. $self->right. "($rval)";
}

sub eval($self)
{
    if    ( $self->hasValue )     { return $self->value; }

    my  $sym = SymbolTable->instance();
    my $left  = $sym->lookup($self->left);
    my $right = $sym->lookup($self->right);
    if    ( $self->op eq '+' ) { $self->value ( $left->eval() + $right->eval() ) }
    elsif ( $self->op eq '-' ) { $self->value ( $left->eval() - $right->eval() ) }
    elsif ( $self->op eq '*' ) { $self->value ( $left->eval() * $right->eval() ) }
    elsif ( $self->op eq '/' ) { $self->value ( $left->eval() / $right->eval() ) }
    return $self->value;
}

1;
