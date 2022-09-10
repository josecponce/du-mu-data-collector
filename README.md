# MU Data Collector Hud

## Special Thanks:
- Wolfe: for his great work on [du-luac](https://github.com/wolfe-labs/DU-LuaC)
- Jericho: for the tons of code I stole from his [DU-Industry-HUD](https://github.com/Jericho1060/DU-Industry-HUD) 
 and [du-storage-monitoring](https://github.com/Jericho1060/du-storage-monitoring) projects. 

## Features:
- Mining Units data collection: component (usually on a ship) automatically collects data from nearby Broadcaster units 
 (usually around 500m but may vary depending on core sizes).
- Sync Mode: Press Alt + 1 to switch to sync mode. Not recommended, not documented and quite buggy.
- Show/Hide Hud: Alt + 2 to hide the hud. Also, useful to avoid key presses during flight to be interpreted by the Hud. 
- Broadcaster Waypoints: 
  - Store Broadcaster position:
    - Move your ship as close as possible to broadcaster.
    - Select Broadcaster from the list by using up/down/left/right keys.
    - Record position by hitting Alt + Left.
  - Navigate to Broadcaster position:
    - Select Broadcaster from the list by using up/down/left/right keys.
    - Set Waypoint to selected Broadcaster by hitting Alt + Right.

## Known Limitations:
- One Collector can only monitor as many territories as emitter channel names can fit in the receiver configuration (256 chars total?)
- Sync Feature is a bit buggy and doesn't reliably transmit all the info all the time. Check timestamps on the collector
  receiving the info to ensure data was actually transmitted.
- Container fill % is not an estimate of current level but the level at the time the data was collected.
- Let me know if I missed anything else?????

## Parts Required:
- A ship (pocket cheap is often convenient) to deploy the Collector system to.
- databank: 2
- programming board: number of mining territories + 1
- emitter xs: number of mining territories + 1
- receiver xs: number of mining territories + 1

## Setup Instructions:
### Configure Data Collector Component (on the collector ship)
- Deploy programming board, 1 emitter, 1 receiver, and 2 databanks.
- Copy [mu-data-collector.json](out/development/mu-data-collector.json) to programming board.
- Connect in the following order:
    - emitter
    - receiver: connect by right-clicking on programming board -> "Select out plug to link ..." -> receiver
        - if you don't connect exactly this way you're in for a fun debugging session
    - databanks
- Set the channel list of the receiver to a comma separate list of channels from all your Territory MU Broadcasters (not yet configured)
    - E.g: if you have two MU Broadcasters on channels Mine 01 and Mine 02 then just enter "Mine 01,Mine 02"
- Edit Programming Board parameters as needed.
- You can now turn on the programming board and use it but won't be very interesting until you set up Broadcasters and collect some data

### Configure MU/Broadcaster Component (on each mining territory)
- Deploy programming board, 1 emitter and 1 receiver.
- Copy [mu-data-broadcaster.json](out/development/mu-data-broadcaster.json) to programming board.
- Connect in following order:
    - container: may work with a hub but haven't tested
    - emitter
    - receiver: unlike for the collector, connect the receiver here the normal way
    - mining units: up to seven
- Edit programming board parameters:
    - Ensure "ping_channel" parameter value matches the Collector's "broadcast_channel" parameter value
    - Update "broadcast_channel" parameter value to the name of this Territory MU Broadcaster
        - This should be one of the names on the Collector receiver's channel list
        - This is how this broadcaster/territory will be labeled in the hud
- Turn on the programming board once
    - This step is REQUIRED.
    - The programming board will turn itself off right away, that's expected.
- You can now open the Collector hud (if it wasn't already) and see the data from the broadcaster being updated there.

## Developer Notes
### Compile Project
- Install [du-luac](https://github.com/wolfe-labs/DU-LuaC).
- Clone the lib repo on [github](https://github.com/josecponce/du-lib).
- Either copy or symlink the `src` folder from the lib repo inside the `src` folder in this repo with the name du_lib.
- Compile using dua-lua: `du-lua build`