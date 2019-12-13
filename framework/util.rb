# Copyright (c) 2019 Big Ladder Software LLC. All rights reserved.
# See the file "license.txt" for additional terms and conditions.


# Convert a string (e.g., read from CSV) into a value.
def value_from_string(string)
  string = string.to_s  # Make sure value is really a String! otherwise fails
  if (true if Integer(string) rescue false)
    value = string.to_i
  elsif (true if Float(string) rescue false)
    value = string.to_f
  elsif (string == "nil")
    value = "nil"
  elsif (string.downcase == "false")
    value = false
  elsif (string.downcase == "true")
    value = true
  elsif (match = string.match(/(\d*\.?\d*)\s*\|\s*["'](.*)["']/))  # This is close but not perfect
    number, units = match.captures
    value = "#{number.to_f}|\"#{units}\""
  else
    value = "\"#{string}\""
  end
  return(value)
end
