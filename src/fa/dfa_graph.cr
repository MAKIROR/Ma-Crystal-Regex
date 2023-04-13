require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  property states : Set(DFAState)

  def initialize(start_state : DFAState, states : Set(DFAState))
    @start_state = start_state
    @states = states
  end

  def self.default() : DFAGraph
    states_set = Set(DFAState).new
    return DFAGraph.new(DFAState.default(), states_set)
  end

  def minimize()
    accepting_states = @states.select(&.accepting)
    non_accepting_states = @states - accepting_states
    partitions = [accepting_states, non_accepting_states]

    loop do
      new_partitions = [] of Set(DFAState)
      partitions.each do |partition|
        transition_partitions = partition.group_by { |state| state.transitions }
        new_partitions += transition_partitions.values
      end
      break if new_partitions.size == partitions.size
      partitions = new_partitions
    end

    minimized_dfa = DFAGraph.default()
    new_states = Set(DFAState).new

    partitions.each do |partition|
      state = DFAState.default()
      state.accepting = partition.any?(&.accepting)
      state.transitions = partition.first.transitions
      new_states << state
    end

    new_transitions = Hash(DFAState, Hash(Char, DFAState)).new
    new_states.each do |state|
      state.transitions.each do |symbol, next_state|
        new_state = new_states.find { |s| s.transitions == next_state.transitions }
        if !new_state.nil?
          state.add_transition(symbol, new_state)
        end
      end
    end

    new_transitions.each do |state, transitions|
      transitions.each do |symbol, next_state|
        state.add_transition(symbol, next_state)
      end
    end

    new_start_state = new_states.find { |s| s.transitions == @start_state.transitions }
    if !new_start_state.nil?
      @start_state = new_start_state
    end
    @states = new_states
    
  end

end