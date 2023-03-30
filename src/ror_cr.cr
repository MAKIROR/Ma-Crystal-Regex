# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("bc")
  puts [re]
  puts [re.match("bc")]
end