# TODO: Write documentation for `RorCr`
require "./fa/nfa_graph"

module RorCr
  VERSION = "0.1.0"

  regex = "(a|bc(d|ef))"
  states = NFAGraph.new(regex)
end