# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Monkey.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Monkey;

use v5.36;

use Moo;

has id   => ( is => 'ro', required => 1 );
has list => ( is => 'rw', default => sub { [] } );
has op   => ( is => 'ro', required => 1 );
has test => ( is => 'ro', required => 1 );
has ifT  => ( is => 'ro', required => 1 );
has ifF  => ( is => 'ro', required => 1 );

has opref        => ( is => 'rw' );
has inspectCount => ( is => 'rw', default => 0 );

my $MonkeyCollection;

# Use module arithmetic to avoid overflowing worry numbers.
# Need the least common multiple of all the divisors in the test.
my $LCM;

sub show($self)
{
    say "Monkey $self->{id}:";
    say "  Starting items: ", join(", ", $self->list->@*);
    say "  Operation: $self->{op}";
    say "  Test: $self->{test}";
    say "    If true: throw to monkey $self->{ifT}";
    say "    If false throw to monkey $self->{ifF}";
}

sub showList($self)
{
    "Monkey $self->{id}:  " . join(", ", $self->list->@*);
}

sub _parseOperation($operation)
{
    my ($op, $right) = $operation =~ /new = old (.) (\w*)/;
    my $subref;
    if ( $op eq '+' )
    {
        $subref = sub($old) { $old + $right };
    }
    else # op is *
    {
        if ( $right eq 'old' )
        {
            $subref = sub($old) { $old * $old };
        }
        else
        {
            $subref = sub($old) { $old * $right };
        }
    }
    return $subref;
}

sub setCollection($monkeyArray)
{
    $MonkeyCollection = $monkeyArray;

    # Find LCM of all the divisors in the tests
    # Taking shortcut that they're known to be primes
    use List::Util qw/product/;
    $LCM = product map { $_->test } @$MonkeyCollection;
}

sub parse($def)
{
    my ( $monkeyId, @startlist, $operation, $test, $ifTrue, $ifFalse );

    chomp;
    ($monkeyId ) = $def =~ /^Monkey ([0-9]+):/ ;
    if ( $def =~ /Starting items: (.*)$/m )
    {   
        @startlist = map { $_+0 } split(/,/, $1);
    }
    if ( $def =~ /Operation: (.*)$/m )
    {
        $operation = $1;
    }
    if ( $def =~ /Test: divisible by ([0-9]+)/ )
    {
        $test = $1;
    }
    if ( $def =~ /If true: throw to monkey ([0-9]+)/ )
    {
        $ifTrue = $1;
    }
    if ( $def =~ /If false: throw to monkey ([0-9]+)/ )
    {
        $ifFalse = $1;
    }

    return Monkey->new( id   => $monkeyId,
                        list => \@startlist,
                        op   => $operation,
                        opref => _parseOperation($operation),
                        test => $test, ifT  => $ifTrue, ifF  => $ifFalse, 
                    );
}

sub takeTurn($self)
{
    while ( my $worry = shift $self->list->@* )
    {
        $self->inspectCount( $self->inspectCount + 1 );

        # say "Monkey $self->{id} inspects $worry";

        $worry = ( $self->opref->($worry) % $LCM );
        # say "  Worry $self->{op} becomes $worry";
        # $worry = int($worry/3);
        # say "  Bored down to $worry";

        if ( $worry % $self->test == 0 )
        {
            # say "  $worry thrown to $self->{ifT}";
            $MonkeyCollection->[$self->ifT]->catches($worry);
        }
        else
        {
            # say "  $worry thrown to $self->{ifF}";
            $MonkeyCollection->[$self->ifF]->catches($worry);
        }
    }
}

sub catches($self, $worry)
{
    push @{$self->list}, $worry
}

1;
