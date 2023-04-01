# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("..")
  puts [re]
  puts [re.match("bc")]
end