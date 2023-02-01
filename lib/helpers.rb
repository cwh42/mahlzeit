# Helpers for Mahlzeit!

require 'rss_creator'

# check if string contains any of the words from the @ignore-list
def ignore? (string)
  @ignore.any? { |word| string.include?(word) }
end

# find the column start and width for each header
def find_columns (line)
  cols = []
  @headers.each_index do |i|
    start = line.index(@headers[i])
    # set the column width of the last header
    if i > 0
      len = start - cols[i-1][:start]
      cols[i-1][:len] = len
    end
    # store the column position (start) and width (len); use a big number (1000)
    # as a default for len to make sure the very last column just catches the rest of the line
    cols[i] = {name: @headers[i], start: start, len: 1000}
  end
  cols
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
