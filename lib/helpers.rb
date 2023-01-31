# Helpers for Mahlzeit!

def ignore? (string)
  @ignore.any? { |word| string.include?(word) }
end
