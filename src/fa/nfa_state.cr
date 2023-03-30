class NFAState
  property transitions : Hash(Char, Set(NFAState))
  property accepting : Bool

  def initialize()
    @transitions = {} of Char => Set(NFAState)
    @accepting = false
  end

  def add_transition(symbol : Char, state : NFAState)
    @transitions[symbol] ||= Set(NFAState).new
    @transitions[symbol] << state
  end

  def add_epsilon(state : NFAState)
    @transitions['ε'] ||= Set(NFAState).new
    @transitions['ε'] << state
  end
end