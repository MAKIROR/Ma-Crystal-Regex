require "./dfa_state"

class DFAGraph
  property start_state : DFAState

  def initialize(start_state : DFAState)
    @start_state = start_state
  end
end