# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("a\\?b")
  puts re.match("a?b")
  puts re.match("ab")
end