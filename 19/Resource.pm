# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Resource.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

package Resource;

use constant ORE => 0;
use constant CLAY => 1;
use constant OBSIDIAN => 2;
use constant GEODE => 3;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(ORE CLAY OBSIDIAN GEODE);

1;
