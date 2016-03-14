defmodule Exstreme.GraphTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.Graph
  doctest Exstreme.Graph

  test "graph with many nodes has 7 nodes and 7 connections" do
    assert Graph.count_nodes(graph_many_nodes) == 7
    assert Graph.count_connections(graph_many_nodes) == 7
  end

  test "connection stats for graph with many nodes" do
    assert Graph.connections_stats(graph_many_nodes) == %{begin: 1, connected: 5, end: 1}
  end

  test "the start node is n1" do
    assert Graph.find_start_node(graph_many_nodes) == [:n1]
  end
end
