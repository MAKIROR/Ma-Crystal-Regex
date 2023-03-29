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
      end_state.accept = true
      start_state.add_transition(symbol, end_state)

      NFAGraph.new(start_state, [end_state])
    end

    def to_dfa() : DFAGraph
      start_nfa_states = epsilon_closure(@start_state)
      start_dfa_state = DFAState.new(start_nfa_states)
      
      dfa_graph = DFAGraph.new(start_state: start_dfa_state)
      unmarked_dfa_states = [start_dfa_state]
      
      until unmarked_dfa_states.empty?
        current_dfa_state = unmarked_dfa_states.shift
        current_dfa_state.nfa_states.each do |nfa_state|
          nfa_state.transitions.each do |symbol, next_nfa_states|
            if symbol != 'ε' && !nfa_state.transitions.has_key?(symbol)
              next
            end
            next_nfa_states.each do |next_nfa_state|
              next_dfa_state_nfa_states = epsilon_closure(next_nfa_state)
              next_dfa_state = dfa_graph.state_map.fetch(next_dfa_state_nfa_states) do
                DFAState.new(next_dfa_state_nfa_states)
              end
              current_dfa_state.transitions[symbol] = next_dfa_state
            end
          end
        end
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
  accept_state = NFAState.new()

  start_state.add_epsilon(first_nfa.start_state)
  start_state.add_epsilon(second_nfa.start_state)

  first_nfa.end_states.last.add_epsilon(accept_state)
  second_nfa.end_states.last.add_epsilon(accept_state)

  return NFAGraph.new(start_state, [accept_state])
end

def kleene_closure(nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accept_state = NFAState.new()
  
  start_state.add_epsilon(accept_state)
  start_state.add_epsilon(nfa.start_state)
  nfa.end_states.last.add_epsilon(accept_state)
  nfa.end_states.last.add_epsilon(nfa.start_state)

  return NFAGraph.new(start_state, [accept_state])
end

def concat(first_nfa, second_nfa) : NFAGraph
  first_nfa.end_states.last.add_epsilon(second_nfa.start_state)
  return NFAGraph.new(first_nfa.start_state, [second_nfa.end_states.last])
end

def epsilon_closure(nfa_state : NFAState) : Set(NFAState)
  closure = Set(NFAState).new
  closure << nfa_state
  stack = [nfa_state]
  
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