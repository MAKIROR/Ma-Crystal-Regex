require "./nfa_state"

class NFAGraph
    property start_state : State
    property end_states : Array(State)

    def initialize(start_state : State, end_states : Array(State))
      @start_state = start_state
      @end_states = end_states
    end

    def self.generate(regex : String) : NFAGraph
      states = build_nfa(regex)
      nfa = states.pop

      return NFAGraph.new(nfa.start_state, nfa.end_states)
    end

    def self.basic_nfa(symbol : Char) : NFAGraph
      start_state = State.new()
      end_states = State.new()
      start_state.add_transition(symbol, end_states)

      NFAGraph.new(start_state, [end_states])
    end
end

def build_nfa(regex : String) : Array(NFAGraph)
  postfix = to_rpn(regex)

  start_state = State.new()
  stack = [] of NFAGraph

  postfix.each do |symbol|
    case symbol
    when '*'
      nfa = stack.pop
      new_nfa = closure(nfa)
      
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

  puts stack

  return stack
end

def to_rpn(regex : String) : Array(Char)
    operators = {
        '|' => 0,
        '*' => 1
    }
    infix = regex.chars
    postfix = [] of Char
    stack = [] of Char
  
    i = 0
    should_spliced = false
    while i < infix.size
      case infix[i]
      when '\\'
        postfix << '\\'
        postfix << infix[i+1]
        if should_spliced == true 
          postfix << '.'
        end
        should_spliced = true
        i += 1

      when '('
        should_spliced = false
        stack.push(infix[i])

      when ')'
        should_spliced = false
        while stack.last != '('
            postfix << stack.pop
        end
        stack.pop

      when '|', '*'
        should_spliced = false
        while !stack.empty? && stack.last != '(' && operators[stack.last] >= operators[infix[i]]
          postfix << stack.pop
        end
        stack.push(infix[i])
        
      else
        if infix[i] == '.'
          postfix << '#'
        else
          postfix << infix[i]
        end

        if should_spliced == true && !stack.empty? && stack.last == '|'
          postfix << '.'
        end
        should_spliced = true
      end
      i += 1
    end
    while !stack.empty?
      postfix << stack.pop
    end

    puts postfix
    return postfix
end

def union(first_nfa : NFAGraph, second_nfa : NFAGraph) : NFAGraph
  start_state = State.new()
  accept_state = State.new()

  start_state.add_epsilon(first_nfa.start_state)
  start_state.add_epsilon(second_nfa.start_state)

  first_nfa.end_states.last.add_epsilon(accept_state)
  second_nfa.end_states.last.add_epsilon(accept_state)

  return NFAGraph.new(start_state, [accept_state])
end

def closure(nfa : NFAGraph) : NFAGraph
  start_state = State.new()
  accept_state = State.new()
  
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