defmodule Exstreme.GraphBuilderTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphBuilder
  alias Exstreme.Graph
  doctest Exstreme.GraphBuilder

  test "creates a graph" do
    graph_built = GraphBuilder.build(create_graph)
    assert graph_built != create_graph
    Enum.each(graph_built.nodes, fn({_, params}) ->
      assert Keyword.has_key?(params, :pid)
      assert Keyword.has_key?(params, :after_nodes)
      assert Keyword.has_key?(params, :before_nodes)
      assert Keyword.get(params, :pid) != nil
    end)
  end

  test "sends a message to the graph with common nodes" do
    graph_built = GraphBuilder.build(create_graph)
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    start_node_pid = Keyword.get(graph_built.nodes[start_node], :pid)
    last_node_pid = Keyword.get(graph_built.nodes[last_node], :pid)
    GenServer.cast(last_node_pid, {:connect, self})
    GenServer.cast(start_node_pid, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, last_node_pid, {:sum, 2}}}
  end

  test "sends a message to the graph with many nodes" do
    graph_built = GraphBuilder.build(graph_many_nodes)
    [start_node] = Graph.find_start_node(graph_built)
    [last_node] = Graph.find_last_node(graph_built)
    start_node_pid = Keyword.get(graph_built.nodes[start_node], :pid)
    last_node_pid = Keyword.get(graph_built.nodes[last_node], :pid)
    GenServer.cast(last_node_pid, {:connect, self})
    GenServer.cast(start_node_pid, {:next, self, {:sum, 0}})
    assert_receive {_, {:next, last_node_pid, {:sum, 7}}}
  end
end
