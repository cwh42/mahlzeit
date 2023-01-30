#!/usr/bin/env ruby

require 'pdf/reader'
require 'date'
require 'json'

filename = ARGV[0]

headers = ["Angebot", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]

output = {}

PDF::Reader.open(filename) do |reader|
  reader.pages.each do |page|
    #binding.pry
    #page.text.each_line(chomp: true) do |line|
    week = {}
    cols = []
    category = ''
    date = nil
    page.text.split(/\n+/).each do |line|
      if line.start_with?(headers.first)
        headers.each_index do |i|
          start = line.index(headers[i])
          if i > 0
            len = start - cols[i-1][:start]
            cols[i-1][:len] = len
          end
          cols[i] = {name: headers[i], start: start, len: 1000}
        end
      elsif line.include?('enthält') || line.include?('Beilagentausch') || line.include?('Informationen') || line.include?('Änderungen')
        next
      elsif line.match(/\d+\.\d+\.\d{4}/) {|matchdata| date = Date.parse(matchdata.match(0)) }
      elsif cols.any?
        cols.each do |col|
          snip = line[col[:start], col[:len]]&.strip
          next if snip.nil? || snip.empty?

          if col[:name] == 'Angebot'
            category = snip
          elsif category != 'Salat'
            if week[col[:name]].nil?
              week[col[:name]] = {category => snip}
            else
              if week[col[:name]][category].nil?
                week[col[:name]][category] = snip
              else
                week[col[:name]][category] << ' ' << snip
              end
            end
          end
          #p [col[:name], category, snip]
        end
      end
    end
    output[date.strftime('%GW%V')] = week
  end
  puts JSON.pretty_generate(output)
end
