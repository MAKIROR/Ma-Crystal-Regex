require "./dfa_state"

class DFAGraph
  property start_state : DFAState

  def initialize(transition : Hash(Set(NFAState), DFAState))
    # Create a mapping of NFA states to DFA states
    nfa_to_dfa = {} of Set(NFAState) => DFAState
    transition.each do |nfa_states, dfa_state|
      nfa_to_dfa[nfa_states] = dfa_state
    end
  
    # Create the DFA states and transitions
    dfa_states = [] of DFAState
    transition.each do |nfa_states, dfa_state|
      # Create the transitions for the current DFA state
      dfa_transitions = {} of Char => DFAState
      dfa_state.transitions.each do |symbol, next_dfa_state|
        next_nfa_states = next_dfa_state.nfa_states
        next_dfa_state = nfa_to_dfa[next_nfa_states]
        dfa_transitions[symbol] = next_dfa_state
      end
  
      # Create the DFA state with the computed transitions
      accepting = nfa_states.any?(&.accepting)
      new_dfa_state = DFAState.new(dfa_transitions, nfa_states, accepting)
      dfa_states << new_dfa_state
    end
  
    # Find the start state of the DFA graph

    start_state = dfa_states.find { |state| state.nfa_states == transition.keys.first }
    if start_state
      @start_state = start_state
    else
      @start_state = DFAState.default()
    end
  end
end