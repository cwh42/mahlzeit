# Helpers for Mahlzeit!

require 'rss_creator'

# check if string contains any of the words from the @ignore-list
def ignore? (string)
  @ignore.any? { |word| string.include?(word) }
end

# create a regexp to match the table headers
def header_regexp
  pattern = @headers.map{ |header| "(?<#{header}>#{header}\\s*)" }.join
  Regexp.new pattern
end

# create a regexp to split up the lines by fixed-width columns
def line_regexp (line)
  col_widths = line.match(@header_regexp).captures.map { |column| column.length }
  pattern = col_widths.map{|col| "(.{,#{col}})"}.join
  Regexp.new pattern
end

# parse a line of the table body using the given regexp
def parse (line, regexp)
  line.match(regexp).captures.map { |cols| cols.strip }
end

# write RSS feed xml and metadata
def write_rss (data)
  rss = RSScreator.new 'mahlzeit.rss'
  rss.title = 'Mahlzeit!'
  rss.desc = 'Nuremberg Franken Campus\' Canteen Menu Feed'

  data.each do |date, week|
    week.each do |day, menu|
      desc = ''
      menu.each do |cat, dish|
        desc << "<i>#{cat}</i>: #{dish}</br>"
      end
      item = { title: "#{date}, #{day}", link: '–', description: desc }
      rss.add item
    end
  end
  rss.save
end
