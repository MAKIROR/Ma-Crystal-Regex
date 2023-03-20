require "./nfa_state"

class NFAGraph
    @start : State
    @end : State
    @states = [] of State
  
    def initialize(regex : String)
      @start, @end = build_nfa(regex)
    end
  
    def build_nfa(regex : String) : Tuple(State, State)
      postfix = to_rpn(regex)
      state_stack = [] of State
  
      # Improve the process of building NFA
      postfix.each do |symbol|
        case symbol
        when '.'
          # todo
        when '*'
          state = State.new(@states.size)
          @states << state
          prev_state = state_stack.pop
          prev_state.add_transition('#', state)
          state.add_transition('#', prev_state)
          state_stack << state

        when '|'
          state = State.new(@states.size)
          @states << state
          second_state = state_stack.pop
          first_state = state_stack.pop
          state.add_transition('#', first_state)
          state.add_transition('#', second_state)
          state_stack << state

        when '#'
          second_state = state_stack.pop
          first_state = state_stack.pop
          first_state.add_transition(symbol, second_state)
          state_stack << second_state
                    
        else
          state = State.new(@states.size)
          @states << state
          state_stack << state
  
          if symbol == '\\'
            symbol = postfix.shift
          end
  
          prev_state = state_stack.pop
          prev_state.add_transition(symbol, state)
          state_stack << state
        end
      end
  
      return state_stack.pop, state_stack.last
    end

end

def to_rpn(regex : String) : Array(Char)
    operators = {
        '|' => 0,
        '*' => 1,
        '.' => 2
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
      when '|', '*', '.'
        should_spliced = false
        while !stack.empty? && stack.last != '(' && operators[stack.last] >= operators[infix[i]]
          postfix << stack.pop
        end
        if infix[i] == '.'
          stack.push('#')
        else
          stack.push(infix[i])
        end
      else
        postfix << infix[i]
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