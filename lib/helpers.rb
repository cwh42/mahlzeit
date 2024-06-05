# frozen_string_literal: true

# Helpers for Mahlzeit!
LINTER_FIXES = { 'schmorrt' => 'schmort',
                 'wurrst' => 'wurst',
                 /([Kk])lasisch/ => '\1lassisch',
                 'lions' => 'loins', # https://en.wikipedia.org/wiki/Loin#Loins_in_butchery
                 /- +(?=[a-z])/ => '', # fix hyphenation
                 /(?<=-) +(?=[A-Z])/ => '', # remove spaces from compounds
                 /(?<=\d) +(?=€)/ => "\u{00A0}", # make the space in the price tag non-breaking
                 /(?<=\s)[Il|](?=\s)/ => '·' }.freeze # just make it use one kind of separator: the Interpunct

# let #p write to STDERR
def p(*args)
  args.each do |arg|
    warn arg.inspect
  end
end

def past?(week)
  # parsing a week date results in its Monday; add 6 days to get its Sunday
  Date.parse(week) + 6 < Date.today
end

# check if string contains any of the words from the @ignore-list
def ignore?(string)
  @ignore.any? { |word| string.include?(word) }
end

# create a regexp to match the table headers
def header_regexp
  col_patterns = @headers.map { |header| "(#{header}\\s*)" }
  header_pattern = ['^', *col_patterns].join
  p header_pattern if @debug
  Regexp.new header_pattern
end

# create a regexp to split up the lines by fixed-width columns
def line_regexp(line)
  col_widths = line.match(@header_regexp).captures.map(&:length)
  ruler(col_widths) if @debug
  col_widths.pop # remove last column
  pattern = col_widths.map { |col| "(.{,#{col}}\\s|.{#{col}})" }.join
  #                                       ^ increase col to increase tolerance for wider columns
  # col+0 means cols can be at most 1 char wider than the header suggests
  Regexp.new "#{pattern}(.*)" # add a catch-all instead of the last column
end

def ruler(col_widths)
  line = col_widths.map { |col| ' ' * (col - 1) }.join('|')
  p line if @debug
end

# parse a line of the table body using the given regexp
def parse_line(line, regexp)
  line += ' ' * @headers.count # add one space per col for safer pattern matching
  if (m = line.match(regexp))
    m.captures.map(&:strip)
  else
    []
  end
end

def parse(page)
  week = {}
  regexp = nil
  category = ''
  date = nil
  page.split(/\n+/).each do |line|
    p line if @debug

    # ignore lines containing words form the @ignore list
    if ignore?(line)
      p ' -> ignored' if @debug
      next
    end

    # line contains a date formatted like '31.12.2022'; use it as a hash-key later
    next if date.nil? && line.match(/\d+\.\d+\.\d{4}/) { |matchdata| date = Date.parse(matchdata[0]) }

    if regexp.nil?
      if line.match(header_regexp)
        regexp = line_regexp line
        p regexp if @debug
      end
      next
    end

    columns = parse_line line, regexp # parse the line; get an array
    p columns if @debug

    columns.each_index do |i|
      wday = @headers[i]
      snip = columns[i]
      next if snip.empty?

      if i.zero? # first column contains the category of the dish
        category = snip
      elsif category != 'Salat' # Ignore any salad (too healthy)
        if week[wday].nil? # new day for that week?
          week[wday] = { category => snip }
        elsif week[wday][category].nil?
          week[wday][category] = snip # new category for that day?
        else # day and category are already there; just append the current snippet
          week[wday][category] += " #{snip}"
        end
      end
    end
  end
  [date, week]
end

# Fix style, typos etc.
def lint(menu)
  menu.each_value do |day|
    day.transform_values! do |dish|
      LINTER_FIXES.each_pair do |pattern, replacement|
        dish.gsub!(pattern, replacement)
      end
      dish
    end
  end
end
