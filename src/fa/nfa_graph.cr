require "./nfa_state"

class NFAGraph
    @start_state : State
    @end_state : State
  
    #def initialize(regex : String)
      #todo
      #states = build_nfa(regex)
      #nfa = states.pop
      
      #@start_state = nfa
      #@end_state = nfa.end_state
    #end

    def initialize(start_state : State, end_state : State)
      @start_state = start_state
      @end_state = end_state
    end

    def self.basic_nfa(symbol : Char) : NFAGraph
      start_state = State.new(0)
      end_state = State.new(1)
      start_state.add_transition(symbol, end_state)

      NFAGraph.nwe(start_state, end_state)
    end

    def kleene_closure()
      start_state = State.new(0)
      end_state = State.new(1)
      start_state.add_epsilon(end_state)
      end_state.add_epsilon(start_state)
      @end_state.add_epsilon(start_state)
    end

    def append_epsilon(state : State)
      @end_state.add_epsilon(state)
      @end_state = state
    end
end

def build_nfa(regex : String) : Array(State)
  postfix = to_rpn(regex)

  start_state = State.new(0)
  stack = [] of NFAGraph

  postfix.each do |symbol|
    case symbol
    when '*'
      state = stack.pop
      state.kleene_closure()
      stack << state

    when '|'
      # todo
    when '.'
      pre_nfa = stack.pop
      pre_nfa.append_epsilon(State.new(0))
    
      stack << pre_nfa

    else
      state = State.new(stack.size + 1)

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

def union(first_state : State, second_state : State) : State
  #
  start_state = State.new(0);
  first_state.add_epsilon(second_state)

  start_state.add_epsilon(first_state)
  start_state.add_epsilon(second_state)

  return start_state
end

