# srip - Silent Rip

A collection of Bash and Ruby scripts to try to automate the process of ripping Bluray and DVD movies and TV shows.

Rips first title that is 60 minutes or longer, removes non-english audio tracks
unless the main track (e.g. Chinese movies) or tracks that are mono or stereo
when a multichannel track exists, selects 3D tracks and English subtitles

Renames the ripped title, moves it to appropriate folder and sets permissions
for Plex


## Setup

* Clone this repo
* Install and run the MakeMKV GUI
* Go to *Preferences->General*, tick *Expert Mode*, *Advanced->Default selection rule* and enter:

    -sel:all,+sel:audio&(eng|core|havecore),-sel:(havemulti),+sel:mvcvideo,+sel:subtitle&(eng),-sel:special,=100:all,-10:eng

* if you do not want 3D movie content to be ripped change `+sel:mvcvideo` to `-sel:mvcvideo` in the above line
* See http://www.makemkv.com/forum2/viewtopic.php?f=10&t=4386#p17399 for full details of MakeMKVs default selection options
* See http://wiki.indie-it.com/wiki/Blu-Ray for some examples

## Usage

