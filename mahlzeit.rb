#!/usr/bin/env ruby

require 'pdf/reader'
require 'date'
require 'json'
require 'optparse'
require './lib/helpers'

@headers = %w[Angebot Montag Dienstag Mittwoch Donnerstag Freitag]
@ignore = %w[enthält 'Stellen Sie sich' 'und Toppings zusammen' Beilagentausch Informationen Änderungen]
@debug = false

json_file = nil

OptionParser.new do |parser|
  parser.banner = "Usage: #{$0} [-d]"

  parser.on('-d', '--debug', 'Debug output') do |d|
    @debug = d
  end
  
  parser.on('-u', '--update FILE', 'Update <FILE>') do |f|
    json_file = f
  end
end.parse!

filenames = ARGV.select {|param| param.downcase.include?('.pdf') }

if filenames.empty?
  puts 'Give one or more PDF-files to parse as a parameter!'
  exit
end

@header_regexp = header_regexp
p @header_regexp if @debug

output = {}

if json_file
  begin
    File.open json_file do |f|
      output = JSON.load f
    end
  rescue
    puts "File '#{json_file}' not found. Will create new one."
  end
end

filenames.each do |filename|
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      date, week = parse page.text
      # add the week to the output as a hash with ISO 8601 week date, like "2022W40", as a key
      output[date.strftime('%GW%V')] = week
      STDERR.puts '-- new week --' + '-' * 60 if @debug
    end
  end
end

# Print json sorted by keys
json_output = JSON.pretty_generate(Hash[*output.sort.flatten])

if json_file
  File.open json_file, 'w' do |f|
    f.write json_output
  end
elsif
  puts json_output
end
