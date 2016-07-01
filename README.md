# srip - Silent Rip

## Description

Automatically rip movies and TV shows and add them to your Plex library.

### Rips Movies

Rips first title that is 45 minutes or longer, removes non-english audio tracks
unless the main track (e.g. Chinese movies) or tracks that are mono or stereo
when a multichannel track exists, selects 3D tracks and English subtitles

Easily search IMDB to get the correct title and year of the movie.

Renames the ripped title, moves it to appropriate folder and sets permissions
for Plex.

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

Make sure the `libgnome` package is installed for auto disc detection.

## Usage

To run:

    ./srip


Tested on Arch Linux.
