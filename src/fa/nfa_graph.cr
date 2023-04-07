require "./dfa_graph"

class NFAGraph
    property start_state : NFAState
    property end_state : NFAState
    property symbols : Set(Char)

    def initialize(start_state : NFAState, end_state : NFAState)
      @start_state = start_state
      @end_state = end_state
      @symbols = Set(Char).new
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

      NFAGraph.new(start_state, end_state)
    end
    
    def set_symbols(symbols : Set(Char))
      @symbols = symbols
    end

    def to_dfa() : DFAGraph
      dfa_start_state = DFAState.default()
      nfa_start_states = @start_state.epsilon_closure()
      transition = {} of Set(NFAState) => DFAState

      if nfa_start_states.empty?
        start_state_set = Set(NFAState).new << @start_state.dup
        unmarked = [start_state_set]
        transition[start_state_set] = dfa_start_state
      else
        unmarked = [nfa_start_states]
        transition[nfa_start_states] = dfa_start_state
        dfa_start_state.accepting = nfa_start_states.any?(&.accepting)
      end

      dfa_states = Set(DFAState).new
      dfa_states << dfa_start_state

      while !unmarked.empty?
        current_nfa_states = unmarked.pop
        current_dfa_state = transition[current_nfa_states]
        
        @symbols.each do |symbol|
          next_nfa_states = Set(NFAState).new
          accepting = false
          current_nfa_states.each do |nfa_state|
            states, accept = nfa_state.move(symbol)
            next_nfa_states += states
            if accept
              accepting = true
            end
          end
          next_accepting = next_nfa_states.any?(&.accepting)
          next_dfa_state = DFAState.default()
          next_dfa_state.accepting ||= accepting

          if !next_nfa_states.empty?
            if !transition.has_key?(next_nfa_states)
              transition[next_nfa_states] = next_dfa_state
              unmarked << next_nfa_states
            else
              next_dfa_state = transition[next_nfa_states]
            end
            current_dfa_state.transitions[symbol] = transition[next_nfa_states]

          else
            current_dfa_state.transitions[symbol] = next_dfa_state
          end
          dfa_states << next_dfa_state
        end
      end
      dfa = DFAGraph.new(dfa_start_state, dfa_states)
      return dfa
    end
end

def epsilon_closure_set(states)
  closure = states.dup
  states.each do |state|
    closure += state.epsilon_closure()
  end
  closure
end

def build_nfa(postfix : Array(Char)) : NFAGraph
  start_state = NFAState.new()
  stack = [] of NFAGraph
  symbols = Set(Char).new

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
        symbol = postfix.pop
      end

      nfa = NFAGraph.basic_nfa(symbol)
      symbols << symbol
      stack << nfa
    end
  end

  if stack.size == 1
    final_nfa = stack.pop
  else
    final_nfa = stack.shift
    stack.each do |nfa|
      final_nfa = concat(final_nfa, nfa)
    end
  end
  final_nfa.set_symbols(symbols)
  return final_nfa
end

def union(first_nfa : NFAGraph, second_nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  accepting_state.accepting = true
  first_nfa.end_state.accepting = false
  second_nfa.end_state.accepting = false

  start_state.add_epsilon(first_nfa.start_state)
  start_state.add_epsilon(second_nfa.start_state)

  first_nfa.end_state.add_epsilon(accepting_state)
  second_nfa.end_state.add_epsilon(accepting_state)

  return NFAGraph.new(start_state, accepting_state)
end

def kleene_closure(nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  accepting_state.accepting = true
  
  start_state.add_epsilon(accepting_state)
  start_state.add_epsilon(nfa.start_state)
  nfa.end_state.add_epsilon(accepting_state)
  nfa.end_state.add_epsilon(nfa.start_state)

  return NFAGraph.new(start_state, accepting_state)
end

def concat(first_nfa, second_nfa) : NFAGraph
  first_nfa.end_state.add_epsilon(second_nfa.start_state)
  first_nfa.end_state.accepting = false
  return NFAGraph.new(first_nfa.start_state, second_nfa.end_state)
end