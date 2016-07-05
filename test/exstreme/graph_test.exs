defmodule Exstreme.GraphTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.Graph
  doctest Exstreme.Graph

  setup do
    graph = graph_many_nodes
    {:ok, graph: graph, n1: Graph.nid(graph, :n1),
     n3: Graph.nid(graph, :n3), n4: Graph.nid(graph, :n4),
     n5: Graph.nid(graph, :n5), f1: Graph.nid(graph, :f1)}
  end

  test "graph with many nodes has 7 nodes and 7 connections", %{graph: graph} do
    assert Graph.count_nodes(graph) == 7
    assert Graph.count_connections(graph) == 7
  end

  test "connection stats for graph with many nodes", %{graph: graph} do
    assert Graph.connections_stats(graph) == %{begin: 1, connected: 5, end: 1}
  end

  test "the start node is n1", %{graph: graph, n1: n1} do
    assert Graph.find_start_node(graph) == [n1]
  end

  test "the last node is n5", %{graph: graph, n5: n5} do
    assert Graph.find_last_node(graph) == [n5]
  end

  test "the nodes before f1 are n4 and n3", %{graph: graph, f1: f1, n3: n3, n4: n4} do
    res = Graph.get_before_nodes(graph, f1)
    assert res == [n4, n3]
  end

  test "the nodes after f1 are n4 and n3", %{graph: graph, f1: f1, n5: n5} do
    res = Graph.get_after_nodes(graph, f1)
    assert res == [n5]
  end
end
