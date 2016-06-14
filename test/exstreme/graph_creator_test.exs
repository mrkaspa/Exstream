defmodule Exstreme.GraphCreatorTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphCreator
  alias Exstreme.Graph
  doctest Exstreme.GraphCreator

  test "creates a valid graph struct" do
    compare_graph = %Graph{
      nodes: %{n1: params, n2: params},
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
      nodes: %{n1: params, n2: params, n3: params},
      connections: %{n1: :n2, n2: :n3}
    }

    {graph, n3} = GraphCreator.create_node(create_graph, params)
    new_graph = GraphCreator.add_connection(graph, :n2, n3)

    assert new_graph == compare_graph
  end

  test "can add a broadcast an many nodes to the broadcast" do
    compare_graph = %Graph{
      nodes: %{n1: params, n2: params, b1: params_broadcast, n3: params, n4: params},
      connections: %{n1: :n2, n2: :b1, b1: [:n4, :n3]}
    }

    {graph, b1} = GraphCreator.create_broadcast(create_graph, params_broadcast)
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
      nodes: %{n1: params, n2: params, b1: params_broadcast, n3: params, n4: params, f1: params_funnel, n5: params},
      connections: %{n1: :n2, n2: :b1, b1: [:n4, :n3], n3: :f1, n4: :f1, f1: :n5}
    }

    {graph, b1} = GraphCreator.create_broadcast(create_graph, params_broadcast)
    {graph, n3} = GraphCreator.create_node(graph, params)
    {graph, n4} = GraphCreator.create_node(graph, params)
    {graph, f1} = GraphCreator.create_funnel(graph, params_funnel)
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
end
