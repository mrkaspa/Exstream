defmodule Exstreme.GraphBuilder do
  @moduledoc """
  Builds the Graph into a Supervision tree of process
  """
  alias Exstreme.GNode.Broadcast
  alias Exstreme.GNode.Funnel
  alias Exstreme.GNode.Common
  alias Exstreme.Graph
  alias Exstreme.GraphValidator

  @doc """
  Builds the Supervision tree for the graph
  """
  @spec build(Graph.t) :: Graph.t | GraphValidator.error
  def build(graph) do
    with :ok <- GraphValidator.validate(graph) do
      graph
      |> update_nodes_relations
      |> start_nodes
      |> connect_nodes
    end
  end

  #private

  # Returns a Graph with the before_nodes and after_nodes set
  @spec update_nodes_relations(Graph.t) :: Graph.t
  defp update_nodes_relations(graph) do
    update_node_func =
      fn({gnode, params}) ->
        new_params =
          params
          |> Keyword.put(:before_nodes, Graph.get_before_nodes(graph, gnode))
          |> Keyword.put(:after_nodes, Graph.get_after_nodes(graph, gnode))

        {gnode, new_params}
      end

    update_in(graph.nodes, &(&1 |> Enum.map(update_node_func) |> Map.new))
  end

  # Starts all the nodes
  @spec start_nodes(Graph.t) :: Graph.t
  defp start_nodes(graph) do
    update_in(graph.nodes, fn(nodes) ->
      nodes
      |> Enum.map(&start_node/1)
      |> Map.new
    end)
  end

  # Starts a gnode
  @spec start_node({atom, [term: any]}) :: {atom, [key: any]}
  defp start_node({gnode, params}) do
    type = Keyword.get(params, :type)
    params =
      params
      |> Keyword.put(:nid, gnode)
      |> Keyword.put_new(:func, fn(data, _) -> {:ok, data} end)
    {:ok, _} =
      case type do
        :broadcast -> Broadcast.start_link(params)
        :funnel -> Funnel.start_link(params)
        _ -> Common.start_link(params)
      end
    {gnode, params}
  end

  # Connects all nodes
  @spec connect_nodes(Graph.t) :: Graph.t
  defp connect_nodes(graph = %Graph{nodes: nodes, connections: connections}) do
    Enum.each(connections, &(connect_pair(&1, nodes)))
    graph
  end

  # Connects two nodes
  @spec connect_pair({atom, [atom]}, %{key: [key: term]}) :: no_return
  defp connect_pair({from, to}, nodes) when is_list(to) do
    1..Enum.count(to)
    |> Enum.map(fn(_) -> from end)
    |> Enum.zip(to)
    |> Enum.each(&(connect_pair(&1, nodes)))
  end

  # Connects two nodes
  @spec connect_pair({atom, atom}, %{key: [key: term]}) :: no_return
  defp connect_pair({from, to}, nodes) when is_atom(to) do
    nid_from = Keyword.get(nodes[from], :nid)
    nid_to =  Keyword.get(nodes[to], :nid)
    GenServer.cast(nid_from, {:connect, nid_to})
  end
end
