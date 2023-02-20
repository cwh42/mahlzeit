#!/usr/bin/env ruby

require 'pdf/reader'
require 'date'
require 'json'
require 'optparse'
require './lib/helpers'

@headers = %w[Angebot Montag Dienstag Mittwoch Donnerstag Freitag]
@ignore = %w[enthält 'Stellen Sie sich' 'und Toppings zusammen' Beilagentausch Informationen Änderungen]

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

@header_regexp = header_regexp
p @header_regexp if options[:debug]

output = {}

filenames.each do |filename|
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      week = {}
      cols = []
      regexp = nil
      category = ''
      date = nil
      header_length = 0
      page.text.split(/\n+/).each do |line|
        p line if options[:debug]

        # ignore lines containing words form the @ignore list
        next if ignore? line
        # line contains a date formatted like '31.12.2022'; use it as a hash-key later
        next if date.nil? && line.match(/\d+\.\d+\.\d{4}/) {|matchdata| date = Date.parse(matchdata.match(0)) }

        if regexp.nil?
          if line.start_with?(@headers.first)
            header_length = line.length
            regexp = line_regexp line
            p regexp if options[:debug]
          end
          next
        end

        columns = parse line, regexp # parse the line; get an array
        p columns if options[:debug]

        columns.each_index do |i|
          wday = @headers[i]
          snip = columns[i]
          next if snip.empty?

          if i == 0 # first column contains the category of the dish
            category = snip
          elsif category != 'Salat' # Ignore any salad (too healthy)
            if week[wday].nil? # new day for that week?
              week[wday] = {category => snip}
            else
              if week[wday][category].nil? # new category for that day?
                week[wday][category] = snip
              else # day and category are already there; just append the current snippet
                week[wday][category] += " #{snip}"
              end
            end
          end
        end
      end
      # add the week to the output as a hash with ISO 8601 week date, like "2022W40", as a key
      output[date.strftime('%GW%V')] = week
      STDERR.puts "-- new week --#{'-' * 60}" if options[:debug]
    end
  end
end

# Print json sorted by keys
puts JSON.pretty_generate(Hash[*output.sort.flatten])
