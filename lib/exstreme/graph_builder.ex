defmodule Exstreme.GraphBuilder do
  @moduledoc """
  Builds the graph generating a Supervision tree of process for the graph that supervises each node. 
  """
  alias Exstreme.GNode.Broadcast
  alias Exstreme.GNode.Funnel
  alias Exstreme.GNode.Common
  alias Exstreme.Graph
  alias Exstreme.GraphValidator
  alias Exstreme.GraphSupervisor

  @doc """
  Builds the Supervision tree for the graph
  """
  @spec build(Graph.t) :: Graph.t | GraphValidator.error
  def build(graph) do
    with :ok <- GraphValidator.validate(graph) do
      graph
      |> update_nodes_relations
      |> start_graph
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

    update_in(graph.nodes, &(Map.new(Enum.map(&1, update_node_func))))
  end

  @spec start_graph(Graph.t) :: Graph.t
  defp start_graph(graph) do
    graph = update_in(graph.nodes, fn(nodes) ->
      nodes
      |> Enum.map(&setup_node/1)
      |> Map.new
    end)
    case GraphSupervisor.start_link(graph) do
      {:error, msg} ->
        raise ArgumentError, message: msg
      _ -> :ok
    end
    graph
  end

  # setup node's params
  @spec setup_node({atom, [term: any]}) :: {atom, [key: any]}
  defp setup_node({gnode, params}) do
    module = case Keyword.get(params, :type) do
      :broadcast -> Broadcast
      :funnel -> Funnel
      _ -> Common
    end
    params =
      params
      |> Keyword.put(:nid, gnode)
      |> Keyword.put(:module, module)
      |> Keyword.put_new(:func, fn(data, _) -> {:ok, data} end)
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
    :ok = GenServer.call(nid_from, {:connect, nid_to})
  end
end
