defmodule SimpleAgent do

  use GenServer

  @type valid_types :: Atom | Integer | String.t # Atom covers nil & boolean
  @type agent :: Agent.agent

  @moduledoc """
  SimpleAgent is a simplification/abstraction layer around the base Elixir `Agent` module.

  Often times, Agents are used to store a simple value, such as an atom or an integer. This is used as a flag
  or a count which multiple processes can access/update. In these cases, the full `Agent` module is used with
  boilerplate closure code that is repetative, adds noise to the code, and can be eliminated. For example,
  to create an agent, update the value, then retrieve that code, you would run:

      {:ok, agent} = Agent.start_link(fn -> nil end)
      Agent.update(agent, fn _ -> :completed end)
      completed = Agent.get(agent, fn val -> val != nil end)
  
  `SimpleAgent` boils these calls down to a more readable:

      agent = SimpleAgent.start!
      SimpleAgent.update! agent, :completed
      completed = SimpleAgent.equals? agent, :completed

  For Integer manipulation, `SimpleAgent` takes this code:

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

  `SimpleAgent` is very useful in testing. For example:

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
  the full `Agent` module. `SimpleAgent` is for those cases where the "entire state" is a single simple Integer,
  String, or Atom (including nil, true, and false).

  Features:

  * Simple types and updates reduce chances of errors, so all calls raise exceptions instead of requiring boilerplate
    pattern matching, and `start!/2` is available instead of start_link
  * No closures are required.
      * `get!/1` uses &(&1)
      * `update!/2` takes the value instead of a function and uses fn _ -> value end
  * nil support
      * `start!/2` defaults the initial value to nil when not specified
      * `nil?/1` checks for the nil state
      * `clear/1` sets the nil state
  * `increment!/1` and `decrement!/1` allow for simple manipulation of integer states.

  """
  
  @doc """
  Starts an agent with the specified initial value, or nil by default. Second optional parameter is
  the standard GenServer options list.

  ## Return values

  Returns the pid of the server to be used in subsequent calls to other `SimpleAgent` functions.

  """
  @spec start!(valid_types, GenServer.options) :: pid
  def start!(initial_state \\ nil, options \\ []) do
    if is_valid_type(initial_state) do
      {:ok, agent} = Agent.start(fn -> initial_state end, options)
      agent
    else
      raise "Invalid type in SimpleAgent"
    end
  end

  @doc """
  Returns the current state of the agent. If the agent has an invalid type, raises an exception
  """
  @spec get!(agent) :: valid_types
  def get!(agent) do
    val = Agent.get(agent, &(&1))
    if is_valid_type(val) do
      val
    else
      raise "Invalid type in SimpleAgent"
    end
  end

  @doc """
  Updates the state to the new value. Returns the new value.
  """
  @spec update!(agent, valid_types) :: valid_types
  def update!(agent, val) do
    if is_valid_type(val) do
      Agent.update(agent, fn _ -> val end)
      val
    else
      raise "Invalid type in SimpleAgent"
    end
  end

  @doc """
  Returns true or false if the current state is nil
  """
  @spec nil?(agent) :: boolean
  def nil?(agent) do
    equals? agent, nil
  end

  @doc """
  Resets the current state to nil
  """
  @spec clear(agent) :: :ok
  def clear(agent) do
    update! agent, nil
    :ok
  end

  @doc """
  Returns true or false if the current state of the specified agent is the specified value
  """
  @spec equals?(agent, valid_types) :: boolean
  def equals?(agent, val) do
    get!(agent) == val
  end

  @doc """
  Increases the value of the current state by 1. Raises error if current state is not an integer
  """
  @spec increment!(agent) :: Integer
  def increment!(agent) do
    modify_integer!(agent, fn a -> a + 1 end)
  end

  @doc """
  Decreases the value of the current state by 1. Raises error if current state is not an integer
  """
  @spec decrement!(agent) :: Integer
  def decrement!(agent) do
    modify_integer!(agent, fn a -> a - 1 end)
  end

  @spec modify_integer!(agent, fun) :: Integer
  defp modify_integer!(agent, fun) do
    Agent.get_and_update(agent, fn val ->
                            if !is_integer(val) do
                              {:not_an_integer, val}
                            else
                              new_val = fun.(val)
                              {new_val, new_val}
                            end
                          end)
    |> case do
      :not_an_integer -> raise "Invalid type in modify_integer!"
      ret -> ret
    end
  end

  @spec is_valid_type(valid_types) :: true | false
  defp is_valid_type(val) when is_atom(val), do: true # covers nil, true, and false
  defp is_valid_type(val) when is_bitstring(val), do: true
  defp is_valid_type(val) when is_integer(val), do: true
  defp is_valid_type(_), do: false

end