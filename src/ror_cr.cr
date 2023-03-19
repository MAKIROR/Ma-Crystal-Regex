# TODO: Write documentation for `RorCr`
require "./fa/nfa_graph"

module RorCr
  VERSION = "0.1.0"

  regex = "((a|b)cd)*(c|d)."
  postfix = to_rpn(regex)
  puts postfix
end
