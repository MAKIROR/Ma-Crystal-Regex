require "./fa/*"

class MRegex
  @dfa : DFAGraph
    
  def initialize(regex : String)
      postfix = MRegex.to_rpn(regex)
      nfa = NFAGraph.generate(postfix)
      @dfa = nfa.to_dfa()
      @dfa.minimize()
  end

  def match(input : String)
    current_state = @dfa.start_state
    input.each_char.with_index do |char, _|
      if current_state.transitions.has_key?(char)
        current_state = current_state.transitions[char]
      elsif current_state.transitions.has_key?('#')
        current_state = current_state.transitions['#']
      else
        return false
      end
    end
    current_state.accepting
  end

  def self.to_rpn(regex : String) : Array(Char)
    operators = {
        '|' => 2,
        '*' => 1,
        '+' => 1,
        '?' => 1,
    }
    infix = regex.chars
    postfix = [] of Char
    stack = [] of Char
  
    i = 0
    should_splice = false
    while i < infix.size
      case infix[i]
      when '\\'
        postfix << '\\'
        postfix << infix[i+1]
        if should_splice == true 
          postfix << '.'
        end
        should_splice = true
        i += 1

      when '('
        should_splice = false
        stack.push(infix[i])

      when ')'
        should_splice = false
        while stack.last != '('
          postfix << stack.pop
        end
        stack.pop

      when '|', '*', '+', '?'
        should_splice = false
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

        if should_splice == true && !stack.empty? && stack.last == '('
          postfix << '.'
        end
        should_splice = true
      end
      i += 1

    end

    while !stack.empty?
      postfix << stack.pop
    end
    return postfix
  end
end