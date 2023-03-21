require "./nfa_state"

class NFAGraph
    @start : State
    @end : State
    @states = [] of State
  
    def initialize(regex : String)

      start_state = State.new(0)
      @states = [start_state]
      @start = start_state

      @end = build_nfa(regex)
      puts @states
    end
  
    def build_nfa(regex : String) : State
      postfix = to_rpn(regex)
      stack = @states
  
      postfix.each do |symbol|
        case symbol
        when '*'
          state = stack.pop
          new_state = State.new(-1)
          new_state.add_transition('ε', state)
          state.add_transition('ε', new_state)
          stack << new_state

        when '|'
          first_state = stack.pop
          second_state = stack.pop
          new_state = State.new(-1)
          new_state.add_transition('ε', first_state)
          new_state.add_transition('ε', second_state)
          stack << new_state

        when '.'
          first_state = stack.pop
          second_state = stack.pop

          first_state.transitions.each do |symbol, target_states|
            next if symbol == '.'
            target_states.each do |target_state|
              second_state.add_transition(symbol, target_state)
            end
          end
        
          second_state.add_transition('#', first_state)

          stack << second_state
                    
        else
          state = State.new(@states.size)

          if symbol == '\\'
            symbol = postfix.shift
          end
    
          prev_state = stack.pop
          prev_state.add_transition(symbol, state)
          stack << prev_state
          stack << state
        end
      end
  
      return stack.last
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