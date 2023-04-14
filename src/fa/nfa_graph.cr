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
    
    def set_symbols(symbols : Set(Char))
      @symbols = symbols
    end

    def to_dfa() : DFAGraph
      dfa_start_state = DFAState.default()
      transition = {} of Set(NFAState) => DFAState

      nfa_start_states = Set(NFAState).new << @start_state
      unmarked = [nfa_start_states]
      transition[nfa_start_states] = dfa_start_state


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
            accepting ||= accept
          end
          next_dfa_state = DFAState.default()
          next_dfa_state.accepting ||= accepting

          if !next_nfa_states.empty?
            if !transition.has_key?(next_nfa_states)
              transition[next_nfa_states] = next_dfa_state
              unmarked << next_nfa_states
            else
              next_dfa_state = transition[next_nfa_states]
            end
          end
          current_dfa_state.transitions[symbol] = next_dfa_state
          dfa_states << next_dfa_state
        end
      end
      dfa = DFAGraph.new(dfa_start_state, dfa_states)
      return dfa
    end
end

def build_nfa(postfix : Array(Char)) : NFAGraph

  stack = [] of NFAGraph
  symbols = Set(Char).new

  i = 0
  while i < postfix.size
    case postfix[i]
    when '*'
      nfa = stack.pop
      new_nfa = kleene_closure(nfa)
      
      stack << new_nfa

    when '+'
      nfa = stack.pop
      new_nfa = positive_closure(nfa)
      
      stack << new_nfa

    when '?'
      nfa = stack.pop
      new_nfa = question_mark_closure(nfa)
      
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
      symbol = postfix[i]
      if postfix[i] == '\\'
        symbol = postfix[i + 1]
        i += 1
      end
      nfa = basic_nfa(symbol)
      symbols << symbol
      stack << nfa
    end
    i += 1
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

def basic_nfa(symbol : Char) : NFAGraph
  start_state = NFAState.new()
  end_state = NFAState.new()
  end_state.accepting = true
  start_state.add_transition(symbol, end_state)

  NFAGraph.new(start_state, end_state)
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
  nfa.end_state.accepting = false
  
  start_state.add_epsilon(accepting_state)
  start_state.add_epsilon(nfa.start_state)
  nfa.end_state.add_epsilon(accepting_state)
  nfa.end_state.add_epsilon(nfa.start_state)

  return NFAGraph.new(start_state, accepting_state)
end

def positive_closure(nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  accepting_state.accepting = true
  nfa.end_state.accepting = false

  start_state.add_epsilon(nfa.start_state)
  nfa.end_state.add_epsilon(accepting_state)
  accepting_state.add_epsilon(start_state)

  return NFAGraph.new(start_state, accepting_state)
end

def question_mark_closure(nfa : NFAGraph) : NFAGraph
  start_state = NFAState.new()
  accepting_state = NFAState.new()
  nfa.end_state.accepting = false
  accepting_state.accepting = true
  
  start_state.add_epsilon(accepting_state)
  start_state.add_epsilon(nfa.start_state)
  nfa.end_state.add_epsilon(accepting_state)

  return NFAGraph.new(start_state, accepting_state)
end

def concat(first_nfa : NFAGraph, second_nfa : NFAGraph) : NFAGraph
  first_nfa.end_state.add_epsilon(second_nfa.start_state)
  first_nfa.end_state.accepting = false
  return NFAGraph.new(first_nfa.start_state, second_nfa.end_state)
end