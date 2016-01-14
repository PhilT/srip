require 'csv'
require 'active_support/core_ext/string/inflections'

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
          info[:name] = name.titleize
          info[:season] = season.to_i if season
        end
      elsif type == 'TINFO'
        info[:titles][id][:id] = id
        code = code.to_i
        value = row[3]
        if code == CHAPTERS
          info[:titles][id][:chapters] = value.to_i
        elsif code == DURATION
          info[:titles][id][:duration] = to_seconds(value)
        elsif code == SIZE_IN_BYTES
          info[:titles][id][:size_in_bytes] = value.to_i
        elsif code == TITLE_ID
          info[:titles][id][:title_id] = value.to_i
        elsif code == SEGMENT_COUNT
          info[:titles][id][:segment_count] = value.to_i
        elsif code == SEGMENT_MAP
          info[:titles][id][:segment_map] = value
        elsif code == FILENAME
          info[:titles][id][:filename] = value
        elsif code == ORDER
          info[:titles][id][:order] = value.to_i
        end
      end
    end
    info
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

