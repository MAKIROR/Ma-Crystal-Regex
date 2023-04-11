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

  def epsilon_closure() : Tuple(Set(NFAState), Bool)
    closure = Set(NFAState).new
    stack = [self]
    closure << self
    accepting = self.accepting
  
    until stack.empty?
      current_nfa_state = stack.pop
      if current_nfa_state.transitions.has_key?('ε')
        current_nfa_state.transitions['ε'].each do |next_nfa_state|
          closure << next_nfa_state
          stack << next_nfa_state
          accepting ||= next_nfa_state.accepting
        end
      end
    end
    {closure, accepting}
  end
  
  def move(symbol : Char) : Tuple(Set(NFAState), Bool)
    next_states = Set(NFAState).new
    states, states_accept = self.epsilon_closure()
    accepting = states_accept
    
    states.each do |state|
      if state.transitions.has_key?(symbol)
        state.transitions[symbol].each do |state|
          target_states, accept = state.epsilon_closure()
          next_states += target_states
          accepting ||= accept
        end
      end
    end
    
    {next_states, accepting}
  end
end