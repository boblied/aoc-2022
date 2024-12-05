#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

# This is going to be a recursive-descent parser. Eventually.

use v5.36;
use lib ".";

use Node;
use SymbolTable;

my $symtbl = SymbolTable->instance;

readInput();

sub readInput()
{
    while (<>)
    {
        chomp;
        s/://g;
        my @rule = split ' ';

        if ( @rule == 2 )
        {
            my ($name, $value) = @rule;
            $symtbl->insert($name, Variable->new(id => $name, value => $value) );
        }
        else
        {
            my ($name, $left, $op, $right) = @rule;
            $symtbl->insert($name, Expression->new(id => $name,
                                left => $left, op => $op, right => $right) );
        }
    }
}

my $root = $symtbl->lookup("root");
say $root->eval();

say $root->sayEquation();

