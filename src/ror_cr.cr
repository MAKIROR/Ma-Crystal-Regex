# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("bc*")
  r = re.match("bc")
  puts [r]
end