# Avorion - Event Balancer

this mod attempts to simulate the brashness of the attackers that randomly
come to fuck your shit up while you play. space is a very large very sparely
populated thing yet pirates still find you every 7 minutes like clockwork...

## Part I: Simulate space being vast...

By default player events tick roughly every 7 minutes and sector based pirate
attacks every 15. This mod introduces a multipler value for the time that delays
each event. With a default value of 8 this ends up pushing player events out
roughly 40 minutes (there is randomness added) and pirate events every 120.

## Part II: Simulate pirates not being as dumb as Ferengi...

Let us assume that before someone jumps into a sector they scan it first to see
what is up. Players generally do it, we get a green dot for some mass detected
and a yellow dot for mass which would have been harder to detect and we did.
This is a rudimentary system i assume as the game matures it will get better.
I have made the assumption that pirates can basically tell the over all
mass/volume of things with their sensors in a simliar method.

**On the small side...**

> *If a sector has almost nothing in it pirates would not waste the fuel to get
there.*

* If you are a small miner mining you will almost surely not have to fight or
bug out of sectors often.

* The closer to the center you get the higher chance your small miner will be
ignored, as when you get closer people are scanning for larger ships more often
than not.

* If you are a small miner, but bring along some larger backup, the sector
average ship size may rise enough, causing the pirates to there might be
something good here.

**On the large side...**

>If a sector has some big shit in it, it may be too well defended to attack.

* If you have a fleet of frigates, a battlestar, etc, you will almost surely
not have to fight pirates. You would murder them there is no profit in death.

* If you are a single battlestar in an empty galaxy you alone will probably be
too intimidating to attack.

* If you are a single battlestar but are accompanied by your mining or salvage
fleet, the sector average ship size may lower enough, causing the pirates to
think they may be able to pick off some of your fleet and bug out with the
booty.

* The closer to the center you are the more often you will have to fight things.
A fleet that broke the sector average in the start zone may not have the over
all volume to do so near the center without retrofits.

## Part III: Simulate space being even vaster...

There is a flat out 75% chance (by default) that if an event *was* going to
happen, that it will not, because, again, space is fucking huge.

# Configuration Options

All the config options can be found in the `dcc-event-balance/main.lua` file.

## PauseMultiplier (Re: Part I)

Float, Default 8. This value will adjust the delay between events. Default value of 8 puts
a delay of about 40 minutes on player events and 120 minutes on pirate events.

## SkipWindow (Re: Part II)

Float, 0 to 100, Default 33. Sets the percentage of the sector's expected volume
is exempt from attacking. If a sector expects an average ship size of 1500, we
will not attack this sector if the volume averages to be less than 1005 or
higher than 1995. (495 being 33% of 1500)

## SkipWindowCap (Re: Part II)

Integer, Default 10. The more ships that are in the sector the narrower the
SkipWindow becomes. This sets the maximum number of ships that are allowed to
be considered - meaning that with a default of 10, and 11th ship wont make any
difference.

## SkipWindowFlex (Re: Part II)

Float, Default 0.75. How much to flex the SkipWindow by, based on how many ships
are in the sector. With a value of 1.0 for every ship in the sector we would
make that sector 1% less likely to be attacked.

## SkipChance (Re: Part III)

Int, Default 4. This is just a flat out chance that the event will get canceled
for no reason other than luck of the draw to simulate space not being so
populated. Its really just the upper limit of the randomInt function so a value
of 1 would be 100%, 2 would be 50%, 3 would be 33%, 4 would be 25%...


# Patch Install (Not or Lightly Modded Servers)

If your source is clean enough you should be able to patch the game with the
diff files. You do this from a command window. Here is an example of game
installation, adjust the situation to fit your install paths. For this to work
you will need the common GNU tools installed on Windows. On Linux it will just
work.

* Server is installed to `C:\games\avorion`
* Mod is extracted to `C:\games\avorion-event-balance

Knowing this, we can then do...

* Command terminal window with current directory of `C:\games\avorion`
* `cat ..\avorion-event-balance\patches\* | patch -p2`

```
PS C:\games\avorion-server> cat ..\avorion-event-balance\patches\* | patch -p2

(Stripping trailing CRs from patch; use --binary to disable.)
patching file 'data\scripts\events\pirateattack.lua'
(Stripping trailing CRs from patch; use --binary to disable.)
patching file data/scripts/lib/dcc-event-balance/main.lua
(Stripping trailing CRs from patch; use --binary to disable.)
patching file 'data\scripts\player\eventscheduler.lua'
```

# Patch Update (Not or Lightly Modded Servers)

If you are updating this mod, first, remove it, before extracting and installing
the new copy.

```
PS C:\games\avorion-server> cat ..\avorion-event-balance\patches\* | patch -p2 -R

(Stripping trailing CRs from patch; use --binary to disable.)
patching file 'data\scripts\events\pirateattack.lua'
(Stripping trailing CRs from patch; use --binary to disable.)
patching file data/scripts/lib/dcc-event-balance/main.lua
(Stripping trailing CRs from patch; use --binary to disable.)
patching file 'data\scripts\player\eventscheduler.lua'
```

Now you can extract the new copy and do the normal Patch Install section.

# Manual Install (Heavily Modded Servers)

Look at `scripts\lib\dcc-event-balance\main.lua` - at the top of this file is a
list of all the edits that need to be made to stock files. each item listed can
be found in the file it says it can be found in inside a fake little xml
comment. Here is an example.

```lua
-- player\eventscheduler.lua
-- + require event balancer
-- ...
```

So, in the `player\eventscheduler.lua` in this mod you will find a block of code
like this...

```lua
-- <dcc title="require event balancer">
require ("dcc-event-balance/main")
-- </dcc>
```

So your job then is to copy paste that line into your server file in the same
or simliar spot depending on what other edits you already have. Go through the
list till you get them all.
