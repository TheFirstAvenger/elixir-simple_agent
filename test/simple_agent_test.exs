defmodule SimpleAgentTest do
  use ExUnit.Case

  setup do
    valid_types = [:my_val, 5, true, "foo", nil]
    invalid_types = [%{}, HashDict.new, []]
    {:ok, [valid_types: valid_types, invalid_types: invalid_types]}
  end

  test "start success" do
    agent = SimpleAgent.start!
    assert is_pid(agent)
  end

  test "start defaults to nil" do
    agent = SimpleAgent.start!
    assert Agent.get(agent, &(&1)) == nil
  end

  test "start populates state", context do
    Enum.map(context.valid_types, fn valid_type ->
        agent = SimpleAgent.start! valid_type
        assert Agent.get(agent, &(&1)) == valid_type
      end)
  end

  test "start rejects invalid types", context do
    Enum.map(context.invalid_types, fn invalid_type ->
        assert_raise(RuntimeError, "Invalid type in SimpleAgent", fn -> SimpleAgent.start!(invalid_type) end)
      end)
  end

  test "get returns state", context do
    Enum.map(context.valid_types, fn valid_type ->
        agent = SimpleAgent.start! valid_type
        assert SimpleAgent.get!(agent) == valid_type    
      end)
  end

  test "get rejects invalid types", context do
    Enum.map(context.invalid_types, fn invalid_type ->
        {:ok, agent} = Agent.start_link(fn -> invalid_type end)
        assert_raise RuntimeError, "Invalid type in SimpleAgent", fn -> SimpleAgent.get!(agent) end
      end)
  end

  test "update updates state", context do
    agent = SimpleAgent.start!
    Enum.map(context.valid_types, fn valid_type ->
        assert SimpleAgent.update!(agent, valid_type) == valid_type
      end)
  end

  test "update rejects invalid types", context do
    agent = SimpleAgent.start!
    Enum.map(context.invalid_types, fn invalid_type ->
        assert_raise RuntimeError, "Invalid type in SimpleAgent", fn -> SimpleAgent.update!(agent, invalid_type) end
      end)
  end

  test "nil?" do
    agent = SimpleAgent.start!
    assert SimpleAgent.nil? agent
    SimpleAgent.update! agent, :not_nil
    refute SimpleAgent.nil? agent
  end

  test "clear" do
    agent = SimpleAgent.start! :not_nil
    SimpleAgent.clear agent
    assert SimpleAgent.nil? agent
  end

  test "equals? succeeds", context do
    Enum.map(context.valid_types, fn valid_type ->
        agent = SimpleAgent.start! valid_type
        assert SimpleAgent.equals? agent, valid_type
        refute SimpleAgent.equals? agent, :something_else
      end)
  end

  test "increment succeeds" do
    agent = SimpleAgent.start! 0
    assert SimpleAgent.increment!(agent) == 1
    assert SimpleAgent.increment!(agent) == 2
    assert SimpleAgent.increment!(agent) == 3
    assert SimpleAgent.increment!(agent) == 4
  end

  test "increment rejects invalid state" do
    agent = SimpleAgent.start! :an_atom
    assert_raise RuntimeError, "Invalid type in modify_integer!", fn -> SimpleAgent.increment! agent end
  end

  test "decrement succeeds" do
    agent = SimpleAgent.start! 0
    assert SimpleAgent.decrement!(agent) == -1
    assert SimpleAgent.decrement!(agent) == -2
    assert SimpleAgent.decrement!(agent) == -3
    assert SimpleAgent.decrement!(agent) == -4
  end

  test "decrement rejects invalid state" do
    agent = SimpleAgent.start! :an_atom
    assert_raise RuntimeError, "Invalid type in modify_integer!", fn -> SimpleAgent.decrement! agent end
  end

end