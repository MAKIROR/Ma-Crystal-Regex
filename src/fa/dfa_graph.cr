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

    #todo

  end

end