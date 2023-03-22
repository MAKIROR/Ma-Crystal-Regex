class State
  @id : Int32
  property transitions : Hash(Char, Set(State))

  def initialize(@id : Int32)
    @transitions = Hash(Char, Set(State)).new
  end

  def id_plus(n : Int32)
    @id += n
  end

  def add_transition(symbol : Char, state : State)
    @transitions[symbol] ||= Set(State).new
    @transitions[symbol] << state
  end

  def remove_transition(state : State)
    @transitions.each do |symbol, states|
      states.delete(state)
    end
  end
end