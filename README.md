# srip - Silent Rip

## Description

A collection of Bash and Ruby scripts to try to automate the process
of ripping 3D, Bluray and DVD movies and TV shows and preparing it for Plex.

### Rips Movies

Rips first title that is 30 minutes or longer, removes non-english audio tracks
unless the main track (e.g. Chinese movies) or tracks that are mono or stereo
when a multichannel track exists, selects 3D tracks and English subtitles

Renames the ripped title, moves it to appropriate folder and sets permissions
for Plex

### Rips TV Shows

Rips all titles 30 minutes or longer, removes non-english audio tracks
Renames and adds to existing season in specified library incrementing episode numbers
as necessary.

## Setup

* Clone this repo
* Install and run the MakeMKV GUI
* Go to *Preferences->General*, tick *Expert Mode*,
  *Advanced->Default selection rule* and enter:

    -sel:all,+sel:audio&(eng|core|havecore),-sel:(havemulti),+sel:mvcvideo,+sel:subtitle&(eng),-sel:special,=100:all,-10:eng

* if you do not want 3D movie content to be ripped change `+sel:mvcvideo`
  to `-sel:mvcvideo` in the above line
* [MakeMKV default selection options](ttp://www.makemkv.com/forum2/viewtopic.php?f=10&t=4386#p17399)
* [MakeMKV Blu-Ray ripping examples](http://wiki.indie-it.com/wiki/Blu-Ray)

## Usage

To run:

    ./rip [options]

Anything that is required will be asked on the commandline
unless supplied as an option.

To see all available options:

    ./rip --help

Example. To rip a movie without any questions just supply the year it was released:

    ./rip --year=2016
