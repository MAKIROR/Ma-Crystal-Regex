require "./nfa_state"
require "./dfa_graph"

class NFAGraph
    property start_state : NFAState
    property end_states : Array(NFAState)

    def initialize(start_state : NFAState, end_states : Array(NFAState))
      @start_state = start_state
      @end_states = end_states
    end

    def self.generate(postfix : Array(Char)) : NFAGraph
      nfa = build_nfa(postfix)
      return nfa
    end

    def self.basic_nfa(symbol : Char) : NFAGraph
      start_state = NFAState.new()
      end_state = NFAState.new()
      end_state.accepting = true
      start_state.add_transition(symbol, end_state)

      NFAGraph.new(start_state, [end_state])
    end

    def to_dfa() : DFAGraph
      dfa_graph = DFAGraph.new(DFAState.new())
      unmarked_dfa_states = [@start_state]
      
      until unmarked_dfa_states.empty?
        current_dfa_state = unmarked_dfa_states.shift
        # todo
      end
      
      dfa_graph
    end
end

def build_nfa(postfix : Array(Char)) : NFAGraph
  start_state = NFAState.new()
  stack = [] of NFAGraph

  postfix.each do |symbol|
    case symbol
    when '*'
      nfa = stack.pop
      new_nfa = kleene_closure(nfa)
      
      stack << new_nfa

    when '|'
      second_nfa = stack.pop
      first_nfa = stack.pop
      new_nfa = union(first_nfa, second_nfa)
    
      stack << new_nfa

    when '.'
      second_nfa = stack.pop
      first_nfa = stack.pop
      new_nfa = concat(first_nfa, second_nfa)
    
      stack << new_nfa

    else
      if symbol == '\\'
        symbol = postfix.shift
      end

      nfa = NFAGraph.basic_nfa(symbol)

      stack << nfa
    end
  end

  if stack.size == 1
    return stack.pop
  else
    final_nfa = stack.shift
    stack.each do |nfa|
      final_nfa = concat(final_nfa, nfa)
    end
  
    return final_nfa
  end
end

def union(first_nfa : NFAGraph, second_nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  accepting_state.accepting = true

  start_state.add_epsilon(first_nfa.start_state)
  start_state.add_epsilon(second_nfa.start_state)

  first_nfa.end_states.last.add_epsilon(accepting_state)
  second_nfa.end_states.last.add_epsilon(accepting_state)

  return NFAGraph.new(start_state, [accepting_state])
end

def kleene_closure(nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  accepting_state.accepting = true
  
  start_state.add_epsilon(accepting_state)
  start_state.add_epsilon(nfa.start_state)
  nfa.end_states.last.add_epsilon(accepting_state)
  nfa.end_states.last.add_epsilon(nfa.start_state)

  return NFAGraph.new(start_state, [accepting_state])
end

def concat(first_nfa, second_nfa) : NFAGraph
  first_nfa.end_states.last.add_epsilon(second_nfa.start_state)
  return NFAGraph.new(first_nfa.start_state, [second_nfa.end_states.last])
end