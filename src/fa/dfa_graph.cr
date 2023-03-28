require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  property state_map : Hash(Set(NFAState), DFAState)

  def initialize(start_state : DFAState)
    @start_state = start_state
    @state_map = {} of Set(NFAState) => DFAState
  end
end