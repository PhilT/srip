require './immutable'
require 'csv'

module Disc
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

  module_function

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
          if code == DVD
            info[:type] = 'DVD'
          elsif code == BLURAY
            info[:type] = 'BLURAY'
          else
            raise "Unknown disc type: #{code}"
          end
        elsif id == NAME
          name, season = value.split('SEASON')
          info[:name] = titleize(name)
          info[:season] = season.to_i if season
        end
      elsif type == 'TINFO'
        info[:titles][id][:id] = id
        title_info(info, code.to_i, id, row[3])
      end
    end
    info
  end

  add_to_title = lambda do |fn, info, key, id, value|
    info[:titles][id][key] = send(fn, value)
  end

  add_int_to_title = add_to_title.curry.(Integer)

  add_duration_to_title = add_to_title.curry.(:to_seconds)

  def title_info(info, code, id, value)

    {
      CHAPTERS => :add_int_to_title,
      DURATION => :add_duration_to_title,
      SIZE_IN_BYTES => :add_int_to_title,
      TITLE_ID => :add_int_to_title,
      SEGMENT_COUNT => :add_int_to_title,
      SEGMENT_MAP => :add_to_title,
      FILENAME => :add_to_title,
      ORDER => :add_int_to_title
    }[code].(info, code, id, value)
  end

  def titleize(str)
    str.split('_').map {|part| part[0..0].upcase + part[1..-1].downcase }.join(' ')
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
