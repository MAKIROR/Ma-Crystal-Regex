require "./nfa_state"

class DFAState
    property nfa_states : Set(NFAState)
    property transitions : Hash(Char, DFAState)
  
    def initialize(nfa_states : Set(NFAState))
      @nfa_states = nfa_states
      @transitions = {} of Char => DFAState
    end
  
    def add_transition(symbol : Char, state : DFAState)
      @transitions[symbol] = state
    end
end