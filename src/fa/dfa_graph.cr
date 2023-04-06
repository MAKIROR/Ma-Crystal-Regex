require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  @states : Set(DFAState)

  def initialize(start_state : DFAState, states : Set(DFAState))
    @start_state = start_state
    @states = states
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

    new_states = partitions.map do |partition|
      state = partition.first
      new_transitions = {} of Char => DFAState
      new_transitions = state.transitions.map do |input, transition_state|
        partition_for_state = partitions.find! { |p| p.includes?(transition_state) } || [] of DFAState
        [input.as(Char), partition_for_state.first.as(DFAState)]
      end.to_h
      set = Set(NFAState).new
      DFAState.new({} of Char => DFAState, set, partition.any?(&.accepting)).tap do |new_state|
        new_state.transitions = new_transitions
      end
    end

    reachable_states = [start_state]
    queue = [start_state]

    until queue.empty?
      current_state = queue.shift
      current_state.transitions.values.each do |next_state|
        next unless @states.includes?(next_state)
        next if reachable_states.includes?(next_state)
        reachable_states << next_state
        queue << next_state
      end
    end

    @start_state = reachable_states.first
    @states = reachable_states
  end

end