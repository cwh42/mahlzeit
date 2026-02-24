#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pdf/reader'
require 'date'
require 'json'
require 'optparse'
require './lib/helpers'

@headers = %w[.* Montag Dienstag Mittwoch Donnerstag Freitag]
@ignore = %w[enthält Stellen\ Sie\ sich und\ Toppings\ zusammen Beilagentausch Zusatzstoffe Allergene Änderungen]
@ignore_category = [/salat/i, /^[A-Z][0-9]*$/] # in case allergens slipping in the first column
@debug = false

json_file = nil
cleanup = false
lint = false
v1 = false

OptionParser.new do |parser|
  parser.banner = "Usage: #{$PROGRAM_NAME} [-d]"
  parser.on('-d', '--debug', 'Debug output') { |d| @debug = d }
  parser.on('-u', '--update FILE', 'Update <FILE>') { |f| json_file = f }
  parser.on('-c', '--cleanup', 'Filter past weeks') { |c| cleanup = c }
  parser.on('-l', '--lint', 'Fix some common typos and style issues') { |l| lint = l }
  parser.on('-1', '--v1', 'Use old file format') { |v| v1 = v }
end.parse!

filenames = ARGV.select { |param| param.downcase.include?('.pdf') }

if filenames.empty?
  warn 'Give one or more PDF-files to parse as a parameter!'
  exit
end

@header_regexp = header_regexp

if @debug
  p '@header_regexp:', @header_regexp
  p '@ignore:', @ignore
  p '@ignore_category:', @ignore_category
end

output = {}
output_v2 = {}

if json_file
  begin
    File.open json_file do |f|
      data = JSON.parse f.read #, { symbolize_names: true }

      warn "#{json_file} contains a(n) #{data.class}" if @debug

      case data.class.to_s
      when "Hash"  # v1
        output = data

        data.each do |date, menu|
          v2data = v2ify(Date.parse(date), menu)
          v2data.each do |d|
            output_v2[d[:date]] = d
          end
        end

        out_arr.concat(*data.map { |date, menu| v2ify(Date.parse(date), menu) })
      when "Array" # v2
        if v1
          warn "Not able to convert v2 data to v1."
          exit
        end

        output_v2 = data.to_h { |d| [d['date'], d.transform_keys(&:to_sym)] }
      else
        warn "JSON file seems not to be the right format."
        exit
      end
    end
  rescue Errno::ENOENT
    warn "File '#{json_file}' not found -> creating …"
  end
end

filenames.each do |filename|
  PDF::Reader.open(filename) do |reader|
    reader.pages.each do |page|
      date, menu = parse page.text
      menu = lint(menu) if lint
      # add the week to the output as a hash with ISO 8601 week date, like "2022W40", as a key
      output[date.strftime('%GW%V')] = menu

      v2data = v2ify(date, menu)
      v2data.each do |date|
        output_v2[date[:date]] = date
      end

      warn "-- new week --#{'-' * 60}" if @debug
    rescue RuntimeError => e
      warn "Skip #{filename} due to #{e.message}"
    end
  end
end

# Delete past data, if desired
if cleanup
  output.delete_if { |w| past? w }
  output_v2.delete_if { |d| Date.parse(d) < Date.today }
end

# Print json sorted by keys
json_output = JSON.pretty_generate( v1 ? Hash[*output.sort.flatten] : output_v2.values.sort { |a, b| a[:date] <=> b[:date] })

if json_file
  File.open json_file, 'w' do |f|
    f.write json_output
  end
else
  puts json_output
end
