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

use Node2;
use SymbolTable;

my $symtbl = SymbolTable->instance;

my $Unknown = 'humn';

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

            if ( $name eq $Unknown ) { $value = undef; }  # Part 2

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
my $left = $symtbl->lookup( $root->left );
my $right = $symtbl->lookup( $root->right );

my $lval = $left->eval();
my $rval = $right->eval();

my $target = $lval // $rval;
say "TARGET=$target";

if ( defined $lval )
{
    $right->clear();
    $right->solve($target)
}
else
{
    $left->clear();
    $left->solve($target)
}

say $symtbl->lookup($Unknown)->id, " ", $symtbl->lookup($Unknown)->value;

sub between($beg, $end)
{
    my $interval = ($end - $beg) / 10;
    my @val = map { $beg + $interval*$_ } 0..10;
    return @val;
}

my $humn = $symtbl->lookup($Unknown);
for my $guess ( between( 3587647562850 , 3587647562851  ) )
{
    $left->clear();
    $humn->value($guess);
    $left->eval();
    say $root->showEquation();
    say "guess=$guess diff=", $left->value - $right->value;
}
