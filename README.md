SimpleAgent
===========

  SimpleAgents are an abstraction around Agents.

  Often times, Agents are used to store a simple value, such as an atom or an integer. This is used as a flag
  or a count which multiple processes can access/update. In these cases, the full `Agent` module is used with
  boilerplate closure code that is repetative, adds noise to the code, and can be eliminated. For example,
  to create an agent, update the value, then retrieve that code, you would run:

      {:ok, agent} = Agent.start_link(fn -> nil end)
      Agent.update(agent, fn _ -> :completed end)
      completed = Agent.get(agent, fn val -> val != nil end)
  
  SimpleAgent boils these calls down to a more readable:

      agent = SimpleAgent.start!
      SimpleAgent.update! agent, :completed
      completed = SimpleAgent.equals? agent, :completed

  For Integer manipulation, SimpleAgent takes this code:

      {:ok, agent} = Agent.start_link(fn -> 0 end)
      IO.puts Agent.get_and_update(fn val -> {val + 1, val + 1} end)
      IO.puts Agent.get_and_update(fn val -> {val - 1, val - 1} end)
      IO.puts Agent.get_and_update(fn val -> {val + 1, val + 1} end)
      IO.puts Agent.get_and_update(fn val -> {val + 1, val + 1} end)

  and boils it down to the more readable:

      agent = SimpleAgent.start! 0
      IO.puts SimpleAgent.increment! agent
      IO.puts SimpleAgent.decrement! agent
      IO.puts SimpleAgent.increment! agent
      IO.puts SimpleAgent.increment! agent

  SimpleAgent is very useful in testing. For example:

      test "foo calls bar 3 times" do
        bar_call_agent = SimpleAgent.start! 0
        :meck.new(Bar)
        :meck.expect(Bar, :bar, fn -> SimpleAgent.increment!(bar_call_agent) end)
        Foo.foo()
        assert SimpleAgent.get?(bar_call_agent) == 3
      end
  
  Why only simple types?

  When a complex state such as a map or a dict is in use, the correct way to manipulate the complex state is in
  the Agent server via a closure. This prevents the entire state from being copied from the Agent Server to the
  Client (see the Agent docs for more information on this). For states with these complex types, you should use
  the full `Agent` module. SimpleAgent is for those cases where the "entire state" is a single simple value.

  Features:

  * Simple types and updates reduce chances of errors, so all calls raise exceptions instead of requiring boilerplate
    pattern matching, and `start!/2` is available instead of start_link
  * No closures are required.
      * `get/1` uses &(&1)
      * `update/2` takes the value instead of a function and uses fn _ -> value end
  * nil support
      * `start!/1` defaults the initial value to nil when not specified
      * `nil?/1` checks for the nil state
      * `clear/1` sets the nil state
  * `increment!/1` and `decrement!/1` allow for simple manipulation of integer states.
