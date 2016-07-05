defmodule Exstreme.GraphBuilderTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphBuilder
  alias Exstreme.Graph
  doctest Exstreme.GraphBuilder

  test "creates a graph and check built params" do
    graph_built = GraphBuilder.build(create_graph)
    assert graph_built != create_graph
    Enum.each(graph_built.nodes, fn({nid, params}) ->
      assert Keyword.has_key?(params, :after_nodes)
      assert Keyword.has_key?(params, :before_nodes)
      assert Keyword.get(params, :nid) != nil
      assert nid |> Process.whereis |> Process.alive? == true
    end)
  end

  test "sends a message to the graph with common nodes" do
    graph_built = GraphBuilder.build(create_graph)
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    GenServer.cast(last_node, {:connect, self})
    GenServer.cast(start_node, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, _, {:sum, 2}}}
  end

  test "sends a message to the graph with many nodes" do
    graph_built = GraphBuilder.build(graph_many_nodes)
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    GenServer.cast(last_node, {:connect, self})
    GenServer.cast(start_node, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, _, {:sum, 7}}}
  end
end
