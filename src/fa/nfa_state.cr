class State
  property transitions : Hash(Char, Set(State))

  def initialize()
    @transitions = {} of Char => Set(State)
  end

  def add_transition(symbol : Char, state : State)
    @transitions[symbol] ||= Set(State).new
    @transitions[symbol] << state
  end

  def add_epsilon(state : State)
    @transitions['ε'] ||= Set(State).new
    @transitions['ε'] << state
  end
end