# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("((a|b)?)c")
  puts re.match("aac")
  puts re.match("ac")
  puts re.match("bc")
  puts re.match("c")
end