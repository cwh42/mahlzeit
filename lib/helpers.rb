# Helpers for Mahlzeit!

# let #p write to STDERR
def p(*args)
  return *args.each do |arg|
    STDERR.puts arg.inspect
  end
end

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
  col_widths.pop # remove last column
  pattern = col_widths.map{|col| "(.{,#{col}}\\s|.{#{col}})"}.join
  #                                       ^ increase col to increase tolerance for wider columns
  # col+0 means cols can be at most 1 char wider than the header suggests
  Regexp.new pattern += '(.*)' # add a catch-all instead of the last column
end

# parse a line of the table body using the given regexp
def parse (line, regexp)
  line += ' ' * 6 # add one space per col for safer pattern matching
  if m = line.match(regexp)
    m.captures.map { |cols| cols.strip }
  else
    []
  end
end
