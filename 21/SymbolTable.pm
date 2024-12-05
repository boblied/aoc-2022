# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# SymbolTable.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package SymbolTable;
use v5.36;
use Moo;
with 'MooX::Singleton';

has tbl => ( is => 'rw', default => sub { {} } );

sub insert($self, $id, $thing)
{
    $self->tbl->{$id} = $thing;
}

sub lookup($self, $id)
{
    return $self->tbl->{$id};
}

1;
