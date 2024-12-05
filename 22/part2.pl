#!/usr/bin/env perl
# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# part1.pl
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================

use v5.36;

use List::MoreUtils qw/first_index last_index/;

my @Grid;
my %Cube = ( edgelength => 0,
             side => [
                     { rowBound => [0,0], colBound => [0,0] }, # Unused
                     { rowBound => [0,0], colBound => [0,0] }, # 1
                     { rowBound => [0,0], colBound => [0,0] }, # 2
                     { rowBound => [0,0], colBound => [0,0] }, # 3
                     { rowBound => [0,0], colBound => [0,0] }, # 4
                     { rowBound => [0,0], colBound => [0,0] }, # 5
                     { rowBound => [0,0], colBound => [0,0] }, # 6
                     ]
             );

my %EdgeWrap = (
    1 => { E => [2, 'W' ], S => [3,"N"], W => [4, "W*"], N => [6, "W"] },
    2 => { E => [2, 'E*'], S => [3,"E"], W => [1, "E" ], N => [6, "S"] },
    3 => { E => [2, 'S' ], S => [5,"N"], W => [4, "N" ], N => [1, "S"] },
    4 => { E => [5, 'W' ], S => [3,"N"], W => [1, "W*"], N => [3, "W*"] },
    5 => { E => [2, 'E*'], S => [6,"E"], W => [4, "E" ], N => [3, "S"] },
    6 => { E => [5, 'S' ], S => [2,"N"], W => [1, "N" ], N => [4, "S"] },
);

my @RowBound;
my @ColBound;
my @Path;
my $Facing = 'E';
my @Pos = (0,0);

my %Turn = ( E => { R => 'S', L => 'N' },
             N => { R => 'E', L => 'W' },
             W => { R => 'N', L => 'S' },
             S => { R => 'W', L => 'E' },
);

my %FaceValue = ( E => 0, S => 1, W => 2, N => 3 );

sub turn($facing, $direction)
{
    return $Turn{$facing}{$direction};
}

readInput();
showGrid();

@Pos = findStartPos(\@Grid);

while ( my $action = shift @Path )
{
    print "ACTION: $action ";

    if ( $action =~ m/[RL]/ )
    {
        $Facing = turn($Facing, $action);
        say "now facing $Facing";
    }
    else
    {
        move(\@Grid, \@RowBound, \@ColBound, \@Pos, $Facing, $action);
        say "now at @Pos";
    }
}

say "Final: Facing $Facing, POS=(@Pos)";
# Score is based on 1-indexing
say "Score = 1000*$Pos[0] + 4*$Pos[1] + $FaceValue{$Facing} = ",
        1000*($Pos[0]+1) + 4*($Pos[1]+1) + $FaceValue{$Facing};

sub readInput()
{
    my $maxWidth = 0;
    my $state = 'map';
    while (<>)
    {
        chomp;
        if ( m/^$/ ) { $state = 'path'; next; }

        if ( $state eq 'map' )
        {
            my @row = split '';
            my $len = scalar(@row);

            push @Grid, [ @row ];

            $maxWidth = $len if ( $len > $maxWidth );
        }
        elsif ( $state eq 'path' )
        {
            push @Path, parsePath($_)
        }
    }

    # Pad all rows out to the same width.
    for my $r (  0 .. (scalar(@Grid)-1) )
    {
        my $len = scalar(@{$Grid[$r]});
        push @{$Grid[$r]}, (' ') x ($maxWidth - $len) if ( $len < $maxWidth );
    }

    fold();
}

# There are 64 possible ways to assign the sides into the grid so that
# they can fold into a cube.  They are all reflections and rotations
# of two possible shapes, so there's probably a clever way to exploit
# the symmetry.  However, I don't know that cleverness, so we're just
# going to assume the shape and hard-code which edges connect.

sub fold()
{
    my ($height, $width) = ( scalar(@Grid), scalar(@{$Grid[0]}) );
    my $edgeLen = ( $height > $width ? $height : $width ) / 4;
    
    # +-----+-----+-----+
    # |     |  N  |  N  |
    # |     |W 1 E|W 2 E|
    # |     |  S  |  S  |
    # +-----+-----+-----+
    # |     |  N  |     |
    # |     |W 3 E|     |
    # |     |  S  |     |
    # +-----+-----+-----+
    # |  N  |  N  |     |
    # |W 4 E|W 5 E|     |
    # |  S  |  S  |     |
    # +-----+-----+-----+
    # |  N  |     |     |
    # |W 6 E|     |     |
    # |  S  |     |     |
    # +-----+-----+-----+

    my $s = $Cube{side};
    $s->[1] = { rowBound => [ 0         , $edgeLen*2 -1 ],
                colBound => [ $edgeLen  , $edgeLen*2 -1], };
    $s->[2] = { rowBound => [ 0         , $edgeLen*2 -1],
                colBound => [ $edgeLen  , $edgeLen*3 -1], };
    $s->[3] = { rowBound => [ $edgeLen  , $edgeLen*2 -1],
                colBound => [ $edgeLen  , $edgeLen*2 -1] };
    $s->[4] = { rowBound => [ $edgeLen*2, $edgeLen*3 -1],
                colBound => [ 0         , $edgeLen   -1] };
    $s->[5] = { rowBound => [ $edgeLen*2, $edgeLen*3 -1],
                colBound => [ $edgeLen  , $edgeLen*2 -1] };
    $s->[6] = { rowBound => [ $edgeLen*3, $edgeLen*4 -1],
                colBound => [ 0         , $edgeLen   -1] };

    say "Folded";
}

sub move($g, $rowbound, $colbound, $pos, $facing, $n)
{
    my ($pr, $pc) = $pos->@*;
    if ( $facing eq 'E' )
    {
        my $row = $g->[$pr];
        my ($beg, $end) = $rowbound->[$pr]->@*;
        STEPRIGHT: while ( $n-- )
        {
            my $next = ( $pc == $end ? $beg : $pc + 1 );
            if ( $row->[$next] eq '.' )
            {
                $pc = $next;
            }
            else
            {
                last STEPRIGHT;
            }
        }
        $pos->@* = ($pr, $pc);
    }
    elsif ( $facing eq 'W' )
    {
        my $row = $g->[$pr];
        my ($beg, $end) = $rowbound->[$pr]->@*;
        STEPLEFT: while ( $n-- )
        {
            my $next = ( $pc == $beg ? $end : $pc - 1 );
            if ( $row->[$next] eq '.' )
            {
                $pc = $next;
            }
            else
            {
                last;
            }
        }
        $pos->@* = ($pr, $pc);
    }
    elsif ( $facing eq 'N' )
    {
        my @column = map { $g->[$_][$pc] } 0 .. (scalar(@$g)-1);
        my ($beg, $end) = $colbound->[$pc]->@*;
        STEPUP: while ( $n-- )
        {
            my $next = ( $pr == $beg ? $end : $pr -1 );
            if ( $column[$next] eq '.' )
            {
                $pr = $next;
            }
            else
            {
                last;
            }
        }
        $pos->@* = ($pr, $pc);
    }
    elsif ( $facing eq 'S' )
    {
        my @column = map { $g->[$_][$pc] } 0 .. (scalar(@$g)-1);
        my ($beg, $end) = $colbound->[$pc]->@*;
        STEPDOWN: while ( $n-- )
        {
            my $next = ( $pr == $end ? $beg : $pr + 1 );
            if ( $column[$next] eq '.' )
            {
                $pr = $next;
            }
            else
            {
                last;
            }
        }
        $pos->@* = ($pr, $pc);
    }
}


sub setColBound()
{
    my $width = scalar(@{$Grid[0]});
    for ( my $col = 0 ; $col < $width ; $col++ )
    {
        my @column = map { $Grid[$_][$col] } 0 .. $#Grid;
        my $beg = first_index { $_ ne ' ' } @column;
        my $end = last_index  { $_ ne ' ' } @column;
        push @ColBound, [ $beg, $end ];
    }
}

sub showGrid()
{
    for ( my $r = 0 ; $r <= $#Grid; $r++ )
    {
        printf("%3d ", $r);
        print join("", $Grid[$r]->@*);
        print "\n";
    }
}

sub parsePath($in)
{
    $in =~ s/([RL])/ $1 /g;
    return split(" ", $in);
}

sub findStartPos($g)
{
    for ( my $row = 0; $row < scalar(@$g) ; $row++ )
    {
        my $avail = first_index { $_ eq '.' } $g->[$row]->@*;
        next unless $avail != -1;
        return ($row, $avail);
    }
    return (undef,undef);
}

say "Done";
