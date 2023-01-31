#!/usr/bin/env ruby

require 'pdf/reader'
require 'date'
require 'json'
require 'optparse'
require './lib/helpers'

@headers = %w[Angebot Montag Dienstag Mittwoch Donnerstag Freitag]
@ignore = %w[enthält Beilagentausch Informationen Änderungen]

options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: #{$0} [-d]"

  parser.on("-d", "--debug", "Debug output") do |d|
    options[:debug] = d
  end
end.parse!

filenames = ARGV.select {|param| param.downcase.include?('.pdf') }

if filenames.empty?
  puts "Give one or more PDF-files to parse as a parameter!"
  exit
end

output = {}

filenames.each do |filename|
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      week = {}
      cols = []
      category = ''
      date = nil
      page.text.split(/\n+/).each do |line|
        # ignore lines containing words form the @ignore list
        next if ignore? line
        # line contains a date formatted like '31.12.2022'; use it as a hash-key later
        next if date.nil? && line.match(/\d+\.\d+\.\d{4}/) {|matchdata| date = Date.parse(matchdata.match(0)) }

        if cols.any? # we already got the headers and the column position/with. So let's parse!
          cols.each do |col|
            snip = line[col[:start], col[:len]]&.strip
            next if snip.nil? || snip.empty?

            if col[:name] == @headers.first # We are in the first column; It contains the category of the dish
              category = snip
            elsif category != 'Salat' # Ignore any salad (too healthy)
              if week[col[:name]].nil? # new day for that week?
                week[col[:name]] = {category => snip}
              else
                if week[col[:name]][category].nil? # new category for that day?
                  week[col[:name]][category] = snip
                else # day and category are already there; just append the current snippet
                  week[col[:name]][category] << ' ' << snip
                end
              end
            end
            p [col[:name], category, snip] if options[:debug]
          end
        elsif line.start_with?(@headers.first) # detect the line with column headers
          cols = find_columns(line)
          p cols if options[:debug]
        end
      end
      # add the week to the output as a hash with ISO 8601 week date, like "2022W40", as a key
      output[date.strftime('%GW%V')] = week
      puts "-- new week --#{'-' * 60}" if options[:debug]
    end
  end
end
puts JSON.pretty_generate(output)
