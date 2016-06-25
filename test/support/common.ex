defmodule Exstreme.Common do
  alias Exstreme.GraphCreator
  use ExUnit.CaseTemplate

  using do
    quote do
      def graph_name, do: "demo"

      def graph_many_nodes do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, n1} = GraphCreator.create_node(graph, params)
        {graph, n2} = GraphCreator.create_node(graph, params)
        {graph, b1} = GraphCreator.create_broadcast(graph, params_broadcast)
        {graph, n3} = GraphCreator.create_node(graph, params)
        {graph, n4} = GraphCreator.create_node(graph, params)
        {graph, f1} = GraphCreator.create_funnel(graph, params_funnel)
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

      def graph_one_node_no_connections do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, _n1} = GraphCreator.create_node(graph, params)
        graph
      end

      def graph_no_connections, do: GraphCreator.create_graph(graph_name, [])

      def graph_start_with_broadcast do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, b1} = GraphCreator.create_broadcast(graph, params_broadcast)
        {graph, n1} = GraphCreator.create_node(graph, params)
        GraphCreator.add_connection(graph, b1, n1)
      end

      def graph_start_with_funnnel do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, f1} = GraphCreator.create_funnel(graph, params_funnel)
        {graph, n1} = GraphCreator.create_node(graph, params)
        GraphCreator.add_connection(graph, f1, n1)
      end

      def graph_unconnected_nodes do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, n1} = GraphCreator.create_node(graph, params)
        {graph, n2} = GraphCreator.create_node(graph, params)
        {graph, _n3} = GraphCreator.create_node(graph, params)
        GraphCreator.add_connection(graph, n1, n2)
      end

      defp create_graph do
        graph = GraphCreator.create_graph(graph_name, [])
        {graph, n1} = GraphCreator.create_node(graph, params)
        {graph, n2} = GraphCreator.create_node(graph, params)
        GraphCreator.add_connection(graph, n1, n2)
      end

      def params, do: [type: :common, func: fn({:sum, acc}, _) -> {:ok, {:sum, acc + 1}} end]

      def params_funnel, do: [type: :funnel, func: fn(values, _) -> {:ok, {:sum, Enum.reduce(values, 0, fn({:sum, num}, acc) -> num + acc end)}} end]

      def params_broadcast, do: [type: :broadcast]
    end
  end
end
