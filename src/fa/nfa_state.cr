class State
  @id : Int32
  property transitions : Hash(Char, State)

  def initialize(@id : Int32)
    @transitions = {} of Char => State
  end

  def id_plus(n : Int32)
    @id += n
  end

  def add_transition(symbol : Char, state : State)
    @transitions[symbol] ||= state
  end

  def add_epsilon(state : State)
    @transitions['ε'] ||= state
  end

  def remove_transition(state : State)
    @transitions.each do |symbol, states|
      states.delete(state)
    end
  end
end