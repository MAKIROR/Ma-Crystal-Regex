class DFAState
    property transitions : Hash(Char, DFAState)
    property accepting : Bool

    def initialize(transitions : Hash(Char, DFAState), accepting : Bool = false)
      @transitions = transitions
      @accepting = accepting
    end
  
    def self.default() : DFAState
      set = Set(NFAState).new
      return DFAState.new({} of Char => DFAState, false)
    end
  
    def add_transition(symbol : Char, state : DFAState)
      @transitions[symbol] = state
    end
end