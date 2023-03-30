require "./nfa_state"

class DFAState
    property transitions : Hash(Char, DFAState)
    property accepting : Bool
  
    def initialize()
      @transitions = {} of Char => DFAState
      @accepting = false
    end
  
    def add_transition(symbol : Char, state : DFAState)
      @transitions[symbol] = state
    end
end