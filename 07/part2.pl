#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# 
#=============================================================================

use v5.36;
use Data::Dumper; $Data::Dumper::Sortkeys = 1;
use Carp qw(croak confess);

##########
package Node;

use Moo;

has name   => ( is => 'ro', default => "." );
has size   => ( is => 'rw', default => 0 );
has parent => ( is => 'rw', default => undef );

#####
package File;
use Moo;
extends 'Node';

#####
package Directory;
use Moo;
extends 'Node';

has subdir => ( is => 'rw', default => sub { {} } );
has file   => ( is => 'rw', default => sub { {} } );

sub hasSubdir($self, $dirName)
{
    return exists( $self->{subdir}{$dirName} );
}

sub newSubdir($self, $dirName)
{
    if ( $self->hasSubdir($dirName ) )
    {
        return $self->{subdir}{$dirName};
    }
    else
    {
        my $dir = Directory->new( name => $dirName, parent => $self );
        $self->{subdir}{$dirName} = Directory->new(name => $dirName, parent => $self);
        return $dir;
    }
}

sub newFile($self, $file)
{
    $self->{file}{ $file->name } = $file;
}

sub walk($self, $indent = 0)
{
    say "", (" " x $indent), "[", $self->name, "]\t", $self->size;
    for my $f (sort keys $self->{file}->%* )
    {
        my $fnode = $self->{file}{$f};
        say "  ", (" " x $indent), "$f\t", $fnode->size();
    }
    for my $d ( sort keys $self->{subdir}->%* )
    {
        $self->{subdir}{$d}->walk($indent+2);
    }
}

sub treeSize($self)
{
    $self->size(0);
    for my $f ( keys $self->{file}->%* )
    {
        my $fnode = $self->{file}{$f};
        $self->{size} += $fnode->size();
        # say "$f, ", $fnode->size(), " ", $self->{size};
    }
    for my $d ( keys $self->{subdir}->%* )
    {
        $self->{size} += $self->{subdir}{$d}->treeSize();
    }
    # say $self->name, " TOTAL:", $self->size;
    return $self->size;
}

sub listMaxSize($self, $maxSize)
{
    my @result;
    $self->_listMaxSize($maxSize, \@result);
    return \@result;
}

sub _listMaxSize($self, $maxSize, $accum)
{
    push @$accum, $self if ( $self->size <= $maxSize );
    for my $d ( keys $self->{subdir}->%* )
    {
        $self->{subdir}{$d}->_listMaxSize($maxSize, $accum);
    }
}

sub listMinSize($self, $minSize)
{
    my @result;
    $self->_listMinSize($minSize, \@result);
    return \@result;
}

sub _listMinSize($self, $minSize, $accum)
{
    push @$accum, $self if ( $self->size >= $minSize );
    for my $d ( keys $self->{subdir}->%* )
    {
        $self->{subdir}{$d}->_listMinSize($minSize, $accum);
    }
}

##########
package main;

my $ROOT = Directory->new(name => '/');
$ROOT->parent($ROOT);
my $PWD = $ROOT;

while (<>)
{
    chomp;
    if ( /^\$ cd/ )
    {
        my ($dirName) = (split)[-1];
        if ( $dirName eq "/" )
        {
            $PWD = $ROOT;
        }
        elsif ( $dirName eq ".." )
        {
            $PWD = $PWD->{parent};
        }
        else
        {
            $PWD = $PWD->newSubdir( $dirName );
        }
    }
    elsif ( /\$ ls/ )
    {
    }
    elsif ( /^dir/ )
    {
        my ($dirName) = (split)[-1];
        $PWD->newSubdir($dirName);
    }
    elsif ( /^[0-9]/ )
    {
        my ($size, $name) = split;
        my $f = File->new(name => $name, size => $size, parent => $PWD);
        $PWD->newFile($f);
    }
}

my $DISK = 70000000;
my $NEED = 30000000;

my $Used = $ROOT->treeSize();
my $Available = $DISK - $Used;
my $Find = $NEED - $Available;

my $candidate = $ROOT->listMinSize($Find);
my $smallest = $DISK + 1;
my $pick;
for my $d ( $candidate->@* )
{
    if ( $d->size < $smallest )
    {
        $smallest = $d->size;
        $pick = $d;
    }
}

say $pick->name, "\t", $pick->size;


# $ROOT->walk();
#my $candidate = $ROOT->listMaxSize(100000);
#my $size = 0;
#for my $d ( $candidate->@* )
#{
#    say $d->name, "\t", $d->size;
#    $size += $d->size;
#}
#say "TOTAL: $size";
