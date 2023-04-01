require "./nfa_state"

class DFAState
    property transitions : Hash(Char, DFAState)
    property accepting : Bool

    def initialize(transitions : Hash(Char, DFAState), accepting : Bool)
      @transitions = transitions
      @accepting = accepting
    end
  
    def self.default() : DFAState
      return DFAState.new(transitions: {} of Char => DFAState, accepting: false)
    end
  
    def add_transition(symbol : Char, state : DFAState)
      @transitions[symbol] = state
    end
end