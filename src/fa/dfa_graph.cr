require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  @states : Set(DFAState)

  def initialize(start_state : DFAState, states : Set(DFAState))
    @start_state = start_state
    @states = states
  end

  def minimize()
    
  end
end