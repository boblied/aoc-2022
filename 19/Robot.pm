# vim:set ts=4 sw=4 sts=4 et ai wm=0 nu:
#=============================================================================
# Robot.pm
#=============================================================================
# Copyright (c) 2022, Bob Lied
#=============================================================================
# Description:
#=============================================================================

use v5.36;

package Robot;
use Moo;

sub produce($self)
{
    return 1;
}

1;

package OreRobot;
use Moo;
extends "Robot";

1;

package ClayRobot;
use Moo;
extends "Robot";

1;

package ObsidianRobot;
use Moo;
extends "Robot";

1;

package GeodeRobot;
use Moo;
extends "Robot";

1;
