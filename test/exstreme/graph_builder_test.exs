defmodule Exstreme.GraphBuilderTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphBuilder
  alias Exstreme.Graph
  doctest Exstreme.GraphBuilder

  setup_all do
    {:ok,
      graph_built: GraphBuilder.build(create_graph),
      graph_many_built: GraphBuilder.build(graph_many_nodes("demo_1"))}
  end

  test "crashes when tries to create a graph with the same name" do
    assert_raise ArgumentError, fn ->
      GraphBuilder.build(create_graph("demo_1"))
    end
  end

  test "creates a graph and check built params", %{graph_built: graph_built} do
    assert graph_built != create_graph
    Enum.each(graph_built.nodes, fn({nid, params}) ->
      assert nid != nil
      assert Keyword.has_key?(params, :after_nodes)
      assert Keyword.has_key?(params, :before_nodes)
      assert Keyword.get(params, :nid) != nil
      pid = Process.whereis(nid)
      assert pid != nil
      assert Process.alive?(pid) == true
    end)
  end

  test "sends a message to the graph with common nodes", %{graph_built: graph_built} do
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    :ok = GenServer.call(last_node, {:connect, self})
    GenServer.cast(start_node, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, _, {:sum, 2}}}
  end

  test "sends a message to the graph with many nodes", %{graph_many_built: graph_many_built} do
    [start_node] = Graph.find_start_node(graph_many_built)
    [last_node] = Graph.find_last_node(graph_many_built)
    :ok = GenServer.call(last_node, {:connect, self})
    GenServer.cast(start_node, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, _, {:sum, 7}}}
  end
end
