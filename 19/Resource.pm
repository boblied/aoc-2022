# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Resource.pm
#=============================================================================
# Copyright (c) 2023, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Resource;

use v5.36;

use constant NONE     => -1;
use constant ORE      =>  0;
use constant CLAY     =>  1;
use constant OBSIDIAN =>  2;
use constant GEODE    =>  3;

my @toString = qw( NONE ORE CLAY OBSIDIAN GEODE );

sub resourceName($n) { $toString[$n+1] }

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(NONE ORE CLAY OBSIDIAN GEODE resourceName);

1;
