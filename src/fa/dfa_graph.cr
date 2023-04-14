require "./dfa_state"

class DFAGraph
  property start_state : DFAState
  property states : Set(DFAState)
  @symbols : Set(Char)

  def initialize(start_state : DFAState, states : Set(DFAState), symbols : Set(Char))
    @start_state = start_state
    @states = states
    @symbols = symbols
  end

  def self.default() : DFAGraph
    states_set = Set(DFAState).new
    symbols_set = Set(Char).new
    return DFAGraph.new(DFAState.default(), states_set, symbols_set)
  end

  def minimize()
    accepting_states, non_accepting_states = @states.partition(&.accepting)
    partitions = [accepting_states, non_accepting_states]

    loop do
      new_partitions = [] of Set(DFAState)
      partitions.each do |partition|
        transition_partitions = partition.group_by { |state| state.transitions }
        transition_partitions.values.each do |states|
          new_partitions << states.to_set
        end
      end
      break if new_partitions.size == partitions.size
      partitions = new_partitions
    end

    new_states = Set(DFAState).new

    partitions.each do |partition|
      state = DFAState.new(partition.first.transitions, partition.first.accepting)
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
    
    new_start_state = new_states.find { |s| s.transitions == @start_state.transitions }
    if !new_start_state.nil?
      @start_state = new_start_state
    end
    @states = new_states
  end

end