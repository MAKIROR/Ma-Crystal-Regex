class State
  @id : Int32
  property transitions : Hash(Char, Set(State))

  def initialize(@id : Int32)
    @transitions = Hash(Char, Set(State)).new
  end

  def add_transition(symbol : Char, state : State)
    @transitions[symbol] ||= Set(State).new
    @transitions[symbol] << state
  end

  def epsilon_closure
    closure = Set.new([self])
    stack = [self]

    until stack.empty?
      state = stack.pop

      state.transitions['ε']&.each do |target_state|
        unless closure.include?(target_state)
          closure.add(target_state)
          stack.push(target_state)
        end
      end
    end

    closure
  end
end