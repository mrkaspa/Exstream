defmodule Exstreme.GraphCreatorTest do
  use ExUnit.Case
  alias Exstreme.GraphCreator
  alias Exstreme.Graph
  doctest Exstreme.GraphCreator

  test "creates a valid graph struct" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: []},
      connections: %{n1: :n2}
    }
    assert create_graph == compare_graph
  end

  test "throws an error when adding again the relation" do
    assert_raise ArgumentError, fn ->
      create_graph
      |> GraphCreator.add_connection(:n1, :n2)
    end
  end

  test "throws an error when adding again a self relation" do
    assert_raise FunctionClauseError, fn ->
      create_graph
      |> GraphCreator.add_connection(:n1, :n1)
    end
  end

  test "throws an error when adding a cicle relation" do
    assert_raise ArgumentError, "there is already a connection like that", fn ->
      create_graph
      |> GraphCreator.add_connection(:n2, :n1)
    end
  end

  test "can create n3 and add a relation between n2 and n3" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], n3: []},
      connections: %{n1: :n2, n2: :n3}
    }

    {graph, n3} = GraphCreator.create_node(create_graph, params)
    new_graph = GraphCreator.add_connection(graph, :n2, n3)

    assert new_graph == compare_graph
  end

  test "can add a broadcast an many nodes to the broadcast" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], b1: [], n3: [], n4: []},
      connections: %{n1: :n2, n2: :b1, b1: [:n4, :n3]}
    }

    {graph, b1} = GraphCreator.create_broadcast(create_graph, params)
    {graph, n3} = GraphCreator.create_node(graph, params)
    {graph, n4} = GraphCreator.create_node(graph, params)

    new_graph =
      graph
        |> GraphCreator.add_connection(:n2, b1)
        |> GraphCreator.add_connection(b1, n3)
        |> GraphCreator.add_connection(b1, n4)

    assert new_graph == compare_graph
  end

  test "can add a funnel" do
    compare_graph = %Graph{
      nodes: %{n1: [], n2: [], b1: [], n3: [], n4: [], f1: [], n5: []},
      connections: %{n1: :n2, n2: :b1, b1: [:n4, :n3], n3: :f1, n4: :f1, f1: :n5}
    }

    {graph, b1} = GraphCreator.create_broadcast(create_graph, params)
    {graph, n3} = GraphCreator.create_node(graph, params)
    {graph, n4} = GraphCreator.create_node(graph, params)
    {graph, f1} = GraphCreator.create_funnel(graph, params)
    {graph, n5} = GraphCreator.create_node(graph, params)

    new_graph =
      graph
        |> GraphCreator.add_connection(:n2, b1)
        |> GraphCreator.add_connection(b1, n3)
        |> GraphCreator.add_connection(b1, n4)
        |> GraphCreator.add_connection(n3, f1)
        |> GraphCreator.add_connection(n4, f1)
        |> GraphCreator.add_connection(f1, n5)

    assert new_graph == compare_graph
  end

  # private

  defp params, do: []

  defp create_graph do
    graph = GraphCreator.create_graph(params)
    {graph, n1} = GraphCreator.create_node(graph, params)
    {graph, n2} = GraphCreator.create_node(graph, params)
    GraphCreator.add_connection(graph, n1, n2)
  end
end
