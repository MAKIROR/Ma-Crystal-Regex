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

  def epsilon_closure() : Set(NFAState)
    closure = Set(NFAState).new
    closure << self
    stack = [self]
  
    until stack.empty?
      current_nfa_state = stack.pop
      if current_nfa_state.transitions.has_key?('ε')
        current_nfa_state.transitions['ε'].each do |next_nfa_state|
          unless closure.includes?(next_nfa_state)
            closure << next_nfa_state
            stack << next_nfa_state
          end
        end
      end
    end
    closure
  end
  
  def move(symbol : Char) : Set(NFAState)
    closure = Set(NFAState).new
    closure << self
    stack = [self]
  
    until stack.empty?
      current_nfa_state = stack.pop
      if current_nfa_state.transitions.has_key?(symbol)
        current_nfa_state.transitions[symbol].each do |next_nfa_state|
          unless closure.includes?(next_nfa_state)
            closure << next_nfa_state
            stack << next_nfa_state
          end
        end
      end
    end
    closure
  end
end