# TODO: Write documentation for `RorCr`
require "./fa/nfa_graph"

module RorCr
  VERSION = "0.1.0"

  nfa = NFAGraph.generate("bc*")
  puts [nfa]
end