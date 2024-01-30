#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pdf/reader'
require 'date'
require 'json'
require 'optparse'
require './lib/helpers'

@headers = %w[.* Montag Dienstag Mittwoch Donnerstag Freitag]
@ignore = %w[enthält 'Stellen Sie sich' 'und Toppings zusammen' Beilagentausch Informationen Änderungen]
@debug = false

json_file = nil
cleanup = false
lint = false

OptionParser.new do |parser|
  parser.banner = "Usage: #{$PROGRAM_NAME} [-d]"
  parser.on('-d', '--debug', 'Debug output') { |d| @debug = d }
  parser.on('-u', '--update FILE', 'Update <FILE>') { |f| json_file = f }
  parser.on('-c', '--cleanup', 'Filter past weeks') { |c| cleanup = c }
  parser.on('-l', '--lint', 'Fix some common typos and style issues') { |l| lint = l }
end.parse!

filenames = ARGV.select { |param| param.downcase.include?('.pdf') }

if filenames.empty?
  warn 'Give one or more PDF-files to parse as a parameter!'
  exit
end

@header_regexp = header_regexp
p @header_regexp if @debug

output = {}

if json_file
  begin
    File.open json_file do |f|
      output = JSON.parse f.read
    end
  rescue Errno::ENOENT
    warn "File '#{json_file}' not found. Will create it."
  end
end

filenames.each do |filename|
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      date, menu = parse page.text
      menu = lint(menu) if lint
      # add the week to the output as a hash with ISO 8601 week date, like "2022W40", as a key
      output[date.strftime('%GW%V')] = menu
      warn "-- new week --#{'-' * 60}" if @debug
    end
  end
end

# Delete past weeks, if desired
output.delete_if { |w| past? w } if cleanup

# Print json sorted by keys
json_output = JSON.pretty_generate(Hash[*output.sort.flatten])

if json_file
  File.open json_file, 'w' do |f|
    f.write json_output
  end
else
  puts json_output
end
