defmodule Exstreme.GraphBuilder do
  @moduledoc """
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

  @spec update_nodes_relations(Graph.t) :: Graph.t
  defp update_nodes_relations(graph) do
    update_node_func =
      fn({node, params}) ->
        new_params =
          params
          |> Keyword.put(:before_nodes, Graph.get_before_nodes(graph, node))
          |> Keyword.put(:after_nodes, Graph.get_after_nodes(graph, node))

        {node, new_params}
      end

    update_in(graph.nodes, &(&1 |> Enum.map(update_node_func) |> Map.new))
  end

  @spec start_nodes(Graph.t) :: Graph.t
  defp start_nodes(graph) do
    update_in(graph.nodes, fn(nodes) ->
      nodes
      |> Enum.map(&start_node/1)
      |> Map.new
    end)
  end

  @spec start_node({atom, [term: any]}) :: {atom, [key: any]}
  defp start_node({node, params}) do
    type = Keyword.get(params, :type)
    params = Keyword.put(params, :nid, node)
    {:ok, pid} =
      case type do
        :broadcast -> Broadcast.start_link(params)
        :funnel -> Funnel.start_link(params)
        _ -> Common.start_link(params)
      end
    {node, Keyword.put(params, :pid, pid)}
  end

  @spec connect_nodes(Graph.t) :: Graph.t
  defp connect_nodes(graph = %Graph{nodes: nodes, connections: connections}) do
    Enum.each(connections, &(connect_pair(&1, nodes)))
    graph
  end

  @spec connect_pair({atom, [atom]}, %{key: [key: term]}) :: no_return
  defp connect_pair({from, to}, nodes) when is_list(to) do
    Enum.map(1..Enum.count(to), fn(_) -> from end)
    |> Enum.zip(to)
    |> Enum.each(&(connect_pair(&1, nodes)))
  end

  @spec connect_pair({atom, atom}, %{key: [key: term]}) :: no_return
  defp connect_pair({from, to}, nodes) when is_atom(to) do
    pid_from = Keyword.get(nodes[from], :pid)
    pid_to =  Keyword.get(nodes[to], :pid)
    GenServer.cast(pid_from, {:connect, pid_to})
  end
end
