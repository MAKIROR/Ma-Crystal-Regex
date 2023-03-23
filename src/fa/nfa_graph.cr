require "./nfa_state"

class NFAGraph
    @start : State
    @accept_states : Set(State)
  
    def initialize(regex : String)
      #todo
      
    end

    def new_from_states(start : State, accept_states : Set(State))
      @start = start
      @accept_states = accept_states
    end
end

def build_nfa(regex : String) : NFAGraph
  postfix = to_rpn(regex)

  start_state = State.new(0)
  states = [start_state]
  stack = [] of State

  postfix.each do |symbol|
    case symbol
    when '*'
      state = stack.pop
      new_state = State.new(states.size)
      new_state.add_epsilon(state)
      state.add_epsilon( new_state)
      stack << new_state

    when '|'
      first_state = stack.pop
      second_state = stack.pop
      
      # todo
    when '.'
      first_state = stack.pop
      second_state = stack.pop
    
      second_state.add_epsilon(first_state)
      stack << second_state

    else
      state = State.new(states.size)

      if symbol == '\\'
        symbol = postfix.shift
      end

      prev_state = stack.pop
      prev_state.add_transition(symbol, state)
      stack << prev_state
      stack << state
    end
  end

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

def union(first_state : State, second_state : State) : NFAGraph
  start_state = State(0);
  end_state = State(3)
  first_state.add_epsilon(end_state)
  second_state.add_epsilon(end_state)
  start_state.add_epsilon(first_state)
  start_state.add_epsilon(second_state)

  return NFAGraph.new_from_states(second_state.start, first_state.accept_states)
end