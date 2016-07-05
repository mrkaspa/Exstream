defmodule Exstreme.GraphCreatorTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphCreator
  alias Exstreme.Graph
  doctest Exstreme.GraphCreator

  setup do
    graph = create_graph
    {:ok, graph: graph, n1: Graph.nid(graph, :n1), n2: Graph.nid(graph, :n2 )}
  end

  describe "when the graph is valid" do
    test "creates a valid graph struct", %{graph: graph} do
      compare_graph = %Graph{
        name: graph_name,
        nodes: %{n_demo_1: params, n_demo_2: params},
        connections: %{n_demo_1: :n_demo_2}
      }
      assert graph == compare_graph
    end
  end

  describe "when the graph is invalid" do
    test "throws an error when adding again the relation", %{graph: graph, n1: n1, n2: n2} do
      assert_raise ArgumentError, fn ->
        graph
        |> GraphCreator.add_connection(n1, n2)
      end
    end

    test "throws an error when adding again a self relation", %{graph: graph, n1: n1} do
      assert_raise ArgumentError, "You can't connect to the same node", fn ->
        graph
        |> GraphCreator.add_connection(n1, n1)
      end
    end

    test "throws an error when adding a cicle relation", %{graph: graph, n1: n1, n2: n2} do
      assert_raise ArgumentError, "there is already a connection like that", fn ->
        graph
        |> GraphCreator.add_connection(n2, n1)
      end
    end
  end

  describe "adding nodes" do
    test "can create n3 and add a relation between n2 and n3", %{graph: graph, n2: n2} do
      compare_graph = %Graph{
        name: graph_name,
        nodes: %{n_demo_1: params, n_demo_2: params, n_demo_3: params},
        connections: %{n_demo_1: :n_demo_2, n_demo_2: :n_demo_3}
      }

      {graph, n3} = GraphCreator.create_node(graph, params)
      new_graph = GraphCreator.add_connection(graph, n2, n3)

      assert new_graph == compare_graph
    end

    test "can add a broadcast an many nodes to the broadcast", %{graph: graph, n2: n2} do
      compare_graph = %Graph{
        name: graph_name,
        nodes: %{n_demo_1: params, n_demo_2: params, b_demo_1: params_broadcast, n_demo_3: params, n_demo_4: params},
        connections: %{n_demo_1: :n_demo_2, n_demo_2: :b_demo_1, b_demo_1: [:n_demo_4, :n_demo_3]}
      }

      {graph, b1} = GraphCreator.create_broadcast(graph, params_broadcast)
      {graph, n3} = GraphCreator.create_node(graph, params)
      {graph, n4} = GraphCreator.create_node(graph, params)

      new_graph =
        graph
          |> GraphCreator.add_connection(n2, b1)
          |> GraphCreator.add_connection(b1, n3)
          |> GraphCreator.add_connection(b1, n4)

      assert new_graph == compare_graph
    end

    test "can add a funnel", %{graph: graph, n2: n2} do
      compare_graph = %Graph{
        name: graph_name,
        nodes: %{n_demo_1: params, n_demo_2: params, b_demo_1: params_broadcast, n_demo_3: params, n_demo_4: params, f_demo_1: params_funnel, n_demo_5: params},
        connections: %{n_demo_1: :n_demo_2, n_demo_2: :b_demo_1, b_demo_1: [:n_demo_4, :n_demo_3], n_demo_3: :f_demo_1, n_demo_4: :f_demo_1, f_demo_1: :n_demo_5}
      }

      {graph, b1} = GraphCreator.create_broadcast( graph, params_broadcast)
      {graph, n3} = GraphCreator.create_node(graph, params)
      {graph, n4} = GraphCreator.create_node(graph, params)
      {graph, f1} = GraphCreator.create_funnel(graph, params_funnel)
      {graph, n5} = GraphCreator.create_node(graph, params)

      new_graph =
        graph
          |> GraphCreator.add_connection(n2, b1)
          |> GraphCreator.add_connection(b1, n3)
          |> GraphCreator.add_connection(b1, n4)
          |> GraphCreator.add_connection(n3, f1)
          |> GraphCreator.add_connection(n4, f1)
          |> GraphCreator.add_connection(f1, n5)

      assert new_graph == compare_graph
    end
  end
end
