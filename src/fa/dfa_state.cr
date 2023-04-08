require "./nfa_state"

class DFAState
    property transitions : Hash(Char, DFAState)
    property nfa_states : Set(NFAState)
    property accepting : Bool

    def initialize(transitions : Hash(Char, DFAState), nfa_states : Set(NFAState), accepting : Bool = false)
      @transitions = transitions
      @nfa_states = nfa_states
      @accepting = accepting
    end
  
    def self.default() : DFAState
      set = Set(NFAState).new
      return DFAState.new({} of Char => DFAState, set, false)
    end

    def self.new_from_set(nfa_states : Set(NFAState)) : DFAState
      dfa_state = DFAState.default()
      dfa_state.nfa_states = nfa_states
      return dfa_state
    end 
  
    def add_transition(symbol : Char, state : DFAState)
      @transitions[symbol] = state
    end
end