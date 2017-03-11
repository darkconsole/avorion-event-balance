# Avorion - Event Balancer

This attempts to balance, aka make less annoying and interupting, the random
events which happen while you play.

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
