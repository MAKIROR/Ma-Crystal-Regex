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
  
      postfix.each do |symbol|
        case symbol
        when '*'
          state = State.new(@states.size)
          @states << state
          prev_state = state_stack.pop
          prev_state.add_transition(nil, state)
          state.add_transition(nil, prev_state)
          state_stack << state
        when '|'
          state = State.new(@states.size)
          @states << state
          second_state = state_stack.pop
          first_state = state_stack.pop
          state.add_transition(nil, first_state)
          state.add_transition(nil, second_state)
          state_stack << state
        when '.'
          second_state = state_stack.pop
          first_state = state_stack.pop
          first_state.add_transition(nil, second_state)
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
  
      start_state = state_stack.pop
      return [start_state, @states.last]
    end

end

def to_rpn(regex : String) : Array(Char)
    operators = {
        '|' => 0,
        '.' => 1,
        '*' => 2
    }
    infix = regex.chars
    postfix = [] of Char
    stack = [] of Char
  
    i = 0
    while i < infix.size
      case infix[i]
      when '\\'
        postfix << infix[i+1]
        i += 1
      when '('
        stack.push(infix[i])
      when ')'
        while stack.last != '('
            postfix << stack.pop
        end
        stack.pop
      when '|', '.', '*'
        while !stack.empty? && stack.last != '(' && operators[stack.last] >= operators[infix[i]]
          postfix << stack.pop
        end
        stack.push(infix[i])
      else
        postfix << infix[i]
      end
  
      i += 1
    end
  
    while !stack.empty?
      postfix << stack.pop
    end
  
    return postfix
end