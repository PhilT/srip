#!/bin/env ruby

require 'csv'

# Attribute IDs
TITLE_ID=24
SEGMENT_COUNT=25
SEGMENT_MAP=26
FILENAME=27

# Build data structure from info

#@output = `makemkvcon info disc:0`
@output = File.read('../discinfo.txt')
@info = {}

CSV.parse(@output) do |row|
  type, id = row[0].split(':')
  code = row[1]
  value = row[2]

  if type == 'TCOUNT'
    @info[:title_count] = code
  elsif type == 'CINFO'
  elsif type == 'TINFO'
  end
end

@tvshows = [
  {
    id: /BATTLESTAR_GALACTICA_SEASON(.*)/,
    name: 'Battlestar Galactica'
  }
]

def tvshow
  @discname = @info.match(/^CINFO:2.*?"(.*?)"/)[1]
  @tvshows.first do |show|
    show[:id] =~ discname
  end
end

def dvd?
  @info.match(/CINFO:1,6206/)
end

def season
  show = tvshow
  if show
    @discname.match(show[:id])[1]
  end
end

def title_count
  @title_count ||= @info.match(/^TCOUNT:(.*)/)[1]
end

def titles
  title_count.each do |i|
    @info.match(/TINFO
  end
end

p tvshow
p dvd?
p season

