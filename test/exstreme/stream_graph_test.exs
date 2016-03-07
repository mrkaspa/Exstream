defmodule Exstreme.StreamGraphTest do
  use ExUnit.Case
  alias Exstreme.StreamGraph
  alias Exstreme.StreamGraph.Graph
  doctest Exstreme.StreamGraph

  def params, do: []

  def create_graph do
    with(
      graph       <- StreamGraph.create_graph(params),
      {graph, n1} <- StreamGraph.create_node(graph, params),
      {graph, n2} <- StreamGraph.create_node(graph, params),
      do: StreamGraph.add_connection(graph, n1, n2)
    )
  end

  test "creates a valid graph struct" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: []},
      connections: [{:n1, :n2}]
    }
    assert create_graph == compare_graph
  end

  test "throws an error when adding again the relation" do
    assert_raise ArgumentError, fn ->
      create_graph
      |> StreamGraph.add_connection(:n1, :n2)
    end
  end

  test "throws an error when adding again a self relation" do
    assert_raise FunctionClauseError, fn ->
      create_graph
      |> StreamGraph.add_connection(:n1, :n1)
    end
  end

  test "throws an error when adding a cicle relation" do
    assert_raise ArgumentError, "there is already a connection like that", fn ->
      create_graph
      |> StreamGraph.add_connection(:n2, :n1)
    end
  end

  test "can create n3 and add a relation between n2 and n3" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], n3: []},
      connections: [{:n1, :n2}, {:n2, :n3}]
    }

    new_graph =
      with(
        {graph, n3} <- StreamGraph.create_node(create_graph, params),
        do: graph |> StreamGraph.add_connection(:n2, n3)
      )

    assert new_graph == compare_graph
  end

  test "can add a broadcast an many nodes to the broadcast" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], b1: [], n3: [], n4: []},
      connections: [{:n1, :n2}, {:n2, :b1}, {:b1, [:n4, :n3]}]
    }

    new_graph =
      with(
        {graph, b1} <- StreamGraph.create_broadcast(create_graph, params),
        {graph, n3} <- StreamGraph.create_node(graph, params),
        {graph, n4} <- StreamGraph.create_node(graph, params)
      ) do
          graph
            |> StreamGraph.add_connection(:n2, b1)
            |> StreamGraph.add_connection(b1, n3)
            |> StreamGraph.add_connection(b1, n4)
        end

    assert new_graph == compare_graph
  end

  test "can add a funnel" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], b1: [], n3: [], n4: [], f1: [], n5: []},
      connections: [{:n1, :n2}, {:n2, :b1}, {:b1, [:n4, :n3]}, {:n3, :f1}, {:n4, :f1}, {:f1, :n5}]
    }

    new_graph =
      with(
        {graph, b1} <- StreamGraph.create_broadcast(create_graph, params),
        {graph, n3} <- StreamGraph.create_node(graph, params),
        {graph, n4} <- StreamGraph.create_node(graph, params),
        {graph, f1} <- StreamGraph.create_funnel(graph, params),
        {graph, n5} <- StreamGraph.create_node(graph, params)
      ) do
          graph
            |> StreamGraph.add_connection(:n2, b1)
            |> StreamGraph.add_connection(b1, n3)
            |> StreamGraph.add_connection(b1, n4)
            |> StreamGraph.add_connection(n3, f1)
            |> StreamGraph.add_connection(n4, f1)
            |> StreamGraph.add_connection(f1, n5)
        end

    assert new_graph == compare_graph
  end
end
