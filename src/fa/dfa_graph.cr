require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  property end_states : Set(DFAState)

  def initialize(start_state : DFAState)
    @start_state = start_state
    @end_states = Set(DFAState).new
  end
end