require "./nfa_state"

class Graph
    @start : State
    @end : State
    @states = [] of State

    def initialize(regex : String)
        @start = nil
        @end = nil
        build_nfa(regex)
    end

    private def build_nfa(regex : String)
        stack = [] of Symbol
        postfix = to_postfix(regex)
        counter = 0
    
        regex.chars.each do |c|
            case c
            when "("
                stack << State.new(counter)
                counter += 1

            when ")"
                state = stack.pop
                if stack.last && stack.last != :or
                    stack.last.add_transition(nil, state)
                end
                stack << state

            when "|"
                stack << :or

            when "*"
                state = stack.pop
                state.add_transition(nil, state)
                stack << state

            else
                state = State.new(counter)
                counter += 1
                if stack.last && stack.last != :or
                    stack.last.add_transition(nil, state)
                end
                state.add_transition(c, State.new(counter))
                counter += 1
                stack << state.transitions[c].first
            end
        end

        @end = stack.pop
        raise "Failed to build NFA" unless stack.empty?
        @start = stack.pop
        @states = @start.traverse
    end

end