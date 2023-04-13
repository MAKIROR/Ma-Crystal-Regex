# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("(a|b)")
  puts re.match("ab")
  puts re.match("ac")
  puts re.match("a")
  puts re.match("b")
end