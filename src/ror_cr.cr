# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("(a|b)*")
  puts re.match("aaaaa")
  puts re.match("bbbb")
  puts re.match("c")
end