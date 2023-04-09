# TODO: Write documentation for `RorCr`
require "./regex"

module RorCr
  VERSION = "0.1.0"

  re = MRegex.new("(a*|b)")
  puts re.match("")
  puts re.match("a")
  puts re.match("aaaa")
  puts re.match("b")
  puts re.match("c")
end