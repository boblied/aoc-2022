# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# CPU.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package CPU;

use v5.36;

use Moo;

has register => ( is => 'rw', default => 1 );
has instr    => ( is => 'rw', default => 'start' );
has operand  => ( is => 'rw', default => 0 );
has busy     => ( is => 'rw', default => 0 );

has program  => ( is => 'rw', default => undef );

sub show($self)
{
    print  " X=[".$self->register."] busy=".$self->busy
         . " instr=".$self->instr." arg=".$self->operand
        ;
    if ( $self->isRunning )
    {
        say " progNext=[".$self->program->[0][0]." ".$self->program->[0][1]."]"
    }
    else
    {
        print "\n";
    }
}

my %InstructionSet = (
    noop => { cycle => 1 },
    addx => { cycle => 2 },
);

sub load($self, $program)
{
    $self->program($program);
    return $self;
}

sub isRunning($self)
{
    return $self->instr ne 'end';
}

sub tick($self)
{
    if ( ! $self->busy )
    {
        $self->fetch();
    }

    return $self if $self->instr eq 'end';

    $self->busy($self->busy - 1);

    if ( ! $self->busy )
    {
        $self->execute();
    }
    return $self;
}

sub fetch($self)
{
    my $instruction = shift $self->program()->@*;
    if ( ! defined $instruction)
    {
        $self->instr('end');
        $self->operand(0);
        $self->busy(0);
        return $self;
    }

    my ($op, $arg) = $instruction->@*;
    $self->instr($op);
    $self->operand($arg);
    $self->busy($InstructionSet{$op}{cycle});
    return $self;
}

sub execute($self)
{
    if ( $self->instr eq 'noop' )
    {
        return $self;
    }
    elsif ($self->instr eq 'addx' )
    {
        $self->register($self->register + $self->operand);
    }
    return $self;
}

1;
