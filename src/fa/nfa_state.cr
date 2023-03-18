class State
  @id : Int32
  @transitions : Hash(Char, Set(State))

  def initialize(@id : Int32)
    @transitions = Hash(Char, Set(State)).new
  end

  def add_transition(symbol : Char, state : State)
    transitions[symbol] ||= Set(State).new
    transitions[symbol] << state
  end
  
end