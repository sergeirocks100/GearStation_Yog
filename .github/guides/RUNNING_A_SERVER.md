## INSTALLATION

First-time installation should be fairly straightforward. First, you'll need
BYOND installed. You can get it from https://www.byond.com/download. Once you've done
that, extract the game files to wherever you want to keep them. This is a
sourcecode-only release, so the next step is to compile the server files.
Follow the above steps to do this.

If you see any errors or warnings, something has gone wrong - possibly a corrupt
download or the files extracted wrong. If problems persist, ask for assistance
in #development-public on discord.

Once that's done, open up the config folder. You'll want to edit config.txt to
set the probabilities for different gamemodes in Secret and to set your server
location so that all your players don't get disconnected at the end of each
round. It's recommended you don't turn on the gamemodes with probability 0,
except Extended, as they have various issues and aren't currently being tested,
so they may have unknown and bizarre bugs. Extended is essentially no mode, and
isn't in the Secret rotation by default as it's just not very fun.

You'll also want to edit config/admins.txt to remove the default admins and add
your own. "Game Master" is the highest level of access, and probably the one
you'll want to use for now. You can set up your own ranks and find out more in
config/admin_ranks.txt

The format is

```
byondkey = Rank
```

where the admin rank must be properly capitalised.

This codebase also depends on a native library called rust-g. A precompiled
Windows DLL is included in this repository, but Linux users will need to build
and install it themselves. Directions can be found at the [rust-g
repo](https://github.com/tgstation/rust-g). The `hash` feature is required.

Finally, to start the server, run Dream Daemon and enter the path to your
compiled gearstation.dmb file. Make sure to set the port to the one you
specified in the config.txt, and set the Security box to 'Trusted'. Then press GO
and the server should start up and be ready to join. It is also recommended that
you set up the SQL backend (see below).

## UPDATING

To update an existing installation, first back up your /config and /data folders
as these store your server configuration, player preferences and banlist.

Then, extract the new files (preferably into a clean directory, but updating in
place should work fine), copy your /config and /data folders back into the new
install, overwriting when prompted except if we've specified otherwise, and
recompile the game.  Once you start the server up again, you should be running
the new version.

## HOSTING

If you'd like a more robust server hosting option for tgstation and its
derivatives. Check out /tg/station's server tools suite at 
https://github.com/tgstation/tgstation-server

## MAPS

Yogstation currently comes equipped with the following maps.

* [BoxStation (default)](https://wiki.yogstation.net/wiki/BoxStation)
* [MetaStation](https://wiki.yogstation.net/wiki/MetaStation)
* [NVS Gax](https://wiki.yogstation.net/wiki/NVS_Gax)
* [AsteroidStation](https://wiki.yogstation.net/wiki/AsteroidStation)

All maps have their own code file that is in the base of the _maps directory. Maps are loaded dynamically when the game starts. Follow this guideline when adding your own map, to your fork, for easy compatibility.

The map that will be loaded for the upcoming round is determined by reading data/next_map.json, which is a copy of the json files found in the _maps tree. If this file does not exist, the default map from config/maps.txt will be loaded. Failing that, BoxStation will be loaded. If you want to set a specific map to load next round you can use the Change Map verb in game before restarting the server or copy a json from _maps to data/next_map.json before starting the server. Also, for debugging purposes, ticking a corresponding map's code file in Dream Maker will force that map to load every round.

If you are hosting a server, and want randomly picked maps to be played each round, you can enable map rotation in [config.txt](config/config.txt) and then set the maps to be picked in the [maps.txt](config/maps.txt) file.

Anytime you want to make changes to a map it's imperative you use the [Map Merging tools](https://tgstation13.org/wiki/Map_Merger)

## SQL SETUP

The SQL backend requires a Mariadb server running 10.2 or later. Mysql is not supported but Mariadb is a drop in replacement for mysql. SQL is required for the library, stats tracking, admin notes, and job-only bans, among other features, mostly related to server administration. Your server details go in /config/dbconfig.txt, and the SQL schema is in /SQL/tgstation_schema.sql and /SQL/tgstation_schema_prefix.sql depending on if you want table prefixes.  More detailed setup instructions are located here: https://www.tgstation13.org/wiki/Downloading_the_source_code#Setting_up_the_database

If you are hosting a testing server on windows you can use a standalone version of MariaDB pre load with a blank (but initialized) tgdb database. Find them here: https://tgstation13.download/database/ Just unzip and run for a working (but insecure) database server. Includes a zipped copy of the data folder for easy resetting back to square one.

## WEB/CDN RESOURCE DELIVERY 

Web delivery of game resources makes it quicker for players to join and reduces some of the stress on the game server.

1. Edit compile_options.dm to set the `PRELOAD_RSC` define to `0`
1. Add a url to config/external_rsc_urls pointing to a .zip file containing the .rsc.
    * If you keep up to date with /tg/ you could reuse /tg/'s rsc cdn at http://tgstation13.download/byond/tgstation.zip. Otherwise you can use cdn services like CDN77 or cloudflare (requires adding a page rule to enable caching of the zip), or roll your own cdn using route 53 and vps providers.
	* Regardless even offloading the rsc to a website without a CDN will be a massive improvement over the in game system for transferring files.

## IRC BOT SETUP

Included in the repository is a python3 compatible IRC bot capable of relaying adminhelps to a specified
IRC channel/server, see the /tools/minibot folder for more
