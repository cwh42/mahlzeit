# Helpers for Mahlzeit!

# check if string contains any of the words from the @ignore-list
def ignore? (string)
  @ignore.any? { |word| string.include?(word) }
end

# find the column start and withd for each header
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
