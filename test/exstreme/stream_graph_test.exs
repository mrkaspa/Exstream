defmodule Exstreme.StreamGraphTest do
  use ExUnit.Case
  alias Exstreme.StreamGraph
  alias Exstreme.StreamGraph.Graph
  doctest Exstreme.StreamGraph

  def params, do: []

  def create_graph do
    graph = StreamGraph.create_graph(params)

    {graph, n1} = graph |> StreamGraph.create_node(params)
    {graph, n2} = graph |> StreamGraph.create_node(params)

    graph
    |> StreamGraph.add_connection(n1, n2)
  end

  test "creates a valid graph struct" do
    graph = %Graph{
      nodes: %{n1: [], n2: []},
      connections: [{:n1, :n2}]
    }
    assert create_graph == graph
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

    test "can create n3 and add a relatio between n2 and n3" do
      graph = %Graph{
        nodes: %{n1: [], n2: []},
        connections: [{:n1, :n2}]
      }

      {new_graph, _} = create_graph |> StreamGraph.create_node(params)
      new_graph =
        new_graph
        |> StreamGraph.add_connection(:n2, :n3)
    end
end
