require 'csv'
require './lib/string_util'
require './lib/immutable'

class Disc
  extend Immutable
  include StringUtil

  # Attribute IDs
  TYPE = 1
  NAME = 2
  CHAPTERS = 8
  DURATION = 9
  SIZE_IN_BYTES = 11
  TITLE_ID = 24
  SEGMENT_COUNT = 25
  SEGMENT_MAP = 26
  FILENAME = 27
  ORDER = 33

  DVD = 6206
  BLURAY = 6209
  HDDVD = 6212
  MKV = 6213

  def info(data)
    info = {}

    CSV.parse(data) do |row|
      type, id = row[0].split(':')
      id = id.to_i
      code = row[1].to_i
      value = row[2]

      if type == 'TCOUNT'
        info[:titles] = Array.new(id) { {} }
      elsif type == 'CINFO'
        if id == TYPE
          add_disc_field(info, code)
        elsif id == NAME
          name, season = value.split('SEASON')
          info[:name] = titleize(name)
          info[:season] = season.to_i if season
        end
      elsif type == 'TINFO'
        info[:titles][id][:id] = id
        add_title_field(info, code.to_i, id, row[3])
      end
    end
    info
  end

  def add_disc_field(info, code)
    info[:type] = INFO_MAP[code]
  end

  def add_title_field(info, code, id, value)
    details = INFO_MAP[code]
    info[:titles][id][details[1]] = send(details[0], value) if details
  end

  INFO_MAP = {
    DVD => 'DVD',
    BLURAY => 'BLURAY',
    HDDVD => 'HDDVD',
    MKV => 'MKV',
    NAME => [:noop, :name],
    CHAPTERS => [:to_i, :chapters],
    DURATION => [:to_seconds, :duration],
    SIZE_IN_BYTES => [:to_i, :size_in_bytes],
    TITLE_ID => [:to_i, :title_id],
    SEGMENT_COUNT => [:to_i, :segment_count],
    SEGMENT_MAP => [:noop, :segment_map],
    FILENAME => [:noop, :filename],
    ORDER => [:to_i, :order]
  }

  def noop(value)
    value
  end

  def to_i(value)
    value.to_i
  end

  def to_seconds(time)
    time.
      split(':').
      reverse.
      each_with_index.
      map{|n, i| n.to_i * (60 ** i)}.
      reduce(&:+)
  end
end

