require "./fa/*"

class MRegex
    @dfa : DFAGraph
    
    def initialize(regex : String)
        postfix = to_rpn(regex)
        nfa = NFAGraph.generate(postfix)
        @dfa = nfa.to_dfa()
        @dfa.minimize()
    end

    def match(input : String)
      current_state = @dfa.start_state
      input.each_char.with_index do |char, i|
        if current_state.transitions.has_key?(char)
          current_state = current_state.transitions[char]
        elsif current_state.transitions.has_key?('ε')
          current_state = current_state.transitions['ε']
          next
        else
          puts 0
          return false
        end
      end
      current_state.accepting
    end
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

        if should_spliced == true && !stack.empty? && stack.last == '('
          postfix << '.'
        end
        should_spliced = true
      end
      i += 1
    end
    while !stack.empty?
      postfix << stack.pop
    end

    return postfix
end