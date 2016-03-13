defmodule Exstreme.GraphValidatorTest do
  use ExUnit.Case
  alias Exstreme.{GraphCreator, GraphValidator}
  doctest Exstreme.GraphValidator

  test "the graph with many nodes must be valid" do
    assert :ok = GraphValidator.validate(graph_many_nodes)
  end

  test "the graph with one node must be invalid" do
    assert {:error, _} = GraphValidator.validate(graph_one_node_no_connections)
  end

  test "the graph without connections is invalid" do
    assert {:error, _} = GraphValidator.validate(graph_no_connections)
  end

  test "the graph should start in a node" do
    assert {:error, _} = GraphValidator.validate(graph_start_with_broadcast)
    assert {:error, _} = GraphValidator.validate(graph_start_with_funnnel)
  end

  test "all the nodes in the graph has to be connected" do
    assert {:error, _} = GraphValidator.validate(graph_unconnected_nodes)
  end

  # private

  # valid graphs

  defp graph_many_nodes do
    graph = GraphCreator.create_graph(params)
    {graph, n1} = GraphCreator.create_node(graph, params)
    {graph, n2} = GraphCreator.create_node(graph, params)
    {graph, b1} = GraphCreator.create_broadcast(graph, params)
    {graph, n3} = GraphCreator.create_node(graph, params)
    {graph, n4} = GraphCreator.create_node(graph, params)
    {graph, f1} = GraphCreator.create_funnel(graph, params)
    {graph, n5} = GraphCreator.create_node(graph, params)

    graph
      |> GraphCreator.add_connection(n1, n2)
      |> GraphCreator.add_connection(n2, b1)
      |> GraphCreator.add_connection(b1, n3)
      |> GraphCreator.add_connection(b1, n4)
      |> GraphCreator.add_connection(n3, f1)
      |> GraphCreator.add_connection(n4, f1)
      |> GraphCreator.add_connection(f1, n5)
  end

  # invalid graphs

  defp graph_one_node_no_connections do
    graph = GraphCreator.create_graph(params)
    {graph, _n1} = GraphCreator.create_node(graph, params)
    graph
  end

  defp graph_no_connections, do: GraphCreator.create_graph(params)

  defp graph_start_with_broadcast do
    graph = GraphCreator.create_graph(params)
    {graph, b1} = GraphCreator.create_broadcast(graph, params)
    {graph, n1} = GraphCreator.create_node(graph, params)
    GraphCreator.add_connection(graph, b1, n1)
  end

  defp graph_start_with_funnnel do
    graph = GraphCreator.create_graph(params)
    {graph, f1} = GraphCreator.create_funnel(graph, params)
    {graph, n1} = GraphCreator.create_node(graph, params)
    GraphCreator.add_connection(graph, f1, n1)
  end

  defp graph_unconnected_nodes do
    graph = GraphCreator.create_graph(params)
    {graph, n1} = GraphCreator.create_node(graph, params)
    {graph, n2} = GraphCreator.create_node(graph, params)
    {graph, _n3} = GraphCreator.create_node(graph, params)
    GraphCreator.add_connection(graph, n1, n2)
  end

  defp params, do: []
end
