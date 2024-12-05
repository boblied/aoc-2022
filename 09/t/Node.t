# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu syntax=perl:
#
#===============================================================================
#         FILE: Node.t
#===============================================================================

use v5.36;

use Test2::V0;
use lib "lib";

use Node;

my $head = Node->new(x=>5, y=>5);

is ( Node->new(x=>4, y=>4)->isAdjacent( $head), 1, "LL");
is ( Node->new(x=>4, y=>5)->isAdjacent( $head), 1, "L");
is ( Node->new(x=>4, y=>6)->isAdjacent( $head), 1, "UR");
is ( Node->new(x=>5, y=>4)->isAdjacent( $head), 1, "B");
is ( Node->new(x=>5, y=>5)->isAdjacent( $head), 1, "SAME");
is ( Node->new(x=>5, y=>6)->isAdjacent( $head), 1, "T");
is ( Node->new(x=>6, y=>4)->isAdjacent( $head), 1, "LR");
is ( Node->new(x=>6, y=>5)->isAdjacent( $head), 1, "R");
is ( Node->new(x=>6, y=>6)->isAdjacent( $head), 1, "UR");

isnt ( Node->new(x=>3, y=>4)->isAdjacent( $head), 1, "LL");
isnt ( Node->new(x=>3, y=>5)->isAdjacent( $head), 1, "L");
isnt ( Node->new(x=>3, y=>6)->isAdjacent( $head), 1, "UR");
isnt ( Node->new(x=>5, y=>3)->isAdjacent( $head), 1, "B");
isnt ( Node->new(x=>5, y=>7)->isAdjacent( $head), 1, "T");
isnt ( Node->new(x=>7, y=>4)->isAdjacent( $head), 1, "LR");
isnt ( Node->new(x=>7, y=>5)->isAdjacent( $head), 1, "R");
isnt ( Node->new(x=>7, y=>6)->isAdjacent( $head), 1, "UR");

$head = Node->new(x=>5, y=>5);
$head->moveRight();
ok ( $head->x == 6 && $head->y == 5, "move Right");
$head->moveRight(2);
ok ( $head->x == 8 && $head->y == 5, "move Right 2");
$head->moveLeft();
ok ( $head->x == 7 && $head->y == 5, "move Left");
$head->moveLeft(3);
ok ( $head->x == 4 && $head->y == 5, "move Left 3");

$head = Node->new(x=>5, y=>5);
$head->moveUp();
ok ( $head->x == 5 && $head->y == 6, "move Up");
$head->moveUp(2);
ok ( $head->x == 5 && $head->y == 8, "move Up 2");
$head->moveDown();
ok ( $head->x == 5 && $head->y == 7, "move Down");
$head->moveDown(3);
ok ( $head->x == 5 && $head->y == 4, "move Down 3");

my @diagonal = (
    [ Node->new(x=>5, y=>5), Node->new(x=>3, y=>4), 4, 5, "D X LL", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>3, y=>6), 4, 5, "D X UL", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>7, y=>4), 6, 5, "D X LR", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>7, y=>6), 6, 5, "D X UR"  ],
    [ Node->new(x=>5, y=>5), Node->new(x=>4, y=>3), 5, 4, "D Y LL", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>4, y=>7), 5, 6, "D Y UL", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>6, y=>3), 5, 4, "D Y LR", ],
    [ Node->new(x=>5, y=>5), Node->new(x=>6, y=>7), 5, 6, "D Y UR"  ],
);

for my $tc ( @diagonal )
{
    my $head = $tc->[0];
    my $tail = $tc->[1];

    $tail->moveToward($head);
    ok( $tail->x == $tc->[2] && $tail->y == $tc->[3], $tc->[4] );
}

done_testing;
