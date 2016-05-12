defmodule Exstreme.GraphBuilder do
  @moduledoc """
  """
  alias Exstreme.GNode.Broadcast
  alias Exstreme.GNode.Funnel
  alias Exstreme.GNode.Common

  @doc """
  """
  @spec build(Graph.t) :: Graph.t
  def build(graph) do
    new_graph = update_in(graph.nodes, &start_nodes/1)
    connect_nodes(new_graph)
    new_graph
  end

  #private

  @spec start_nodes(%{key: [key: term]}) :: %{key: [key: term]}
  defp start_nodes(nodes) do
    nodes
    |> Enum.map(&start_node/1)
    |> Map.new
  end

  @spec start_node({atom, [key: any]}) :: {atom, [key: any]}
  defp start_node({node, params = [type: type]}) do
    {:ok, pid} =
      case type do
        :broadcast -> Broadcast.start_link(params)
        :funnel -> Funnel.start_link(params)
        _ -> Common.start_link(params)
      end
    {node, Keyword.put(params, :pid, pid)}
  end

  @spec connect_nodes(Graph.t) :: no_return
  defp connect_nodes(%Graph{nodes: nodes, connections: connections}) do
    Enum.each(connections, &connect_pair/1)
  end

  @spec connect_pair({atom, [atom]}) :: no_return
  defp connect_pair({from, to}) when is_list(to) do
    Enum.map(1..Enum.count(to), fn(_) -> from end)
    |> Enum.zip(to)
    |> Enum.each(&connect_pair/1)
  end

  @spec connect_pair({atom, atom}) :: no_return
  defp connect_pair({from, to}) when is_atom(to) do
    [pid: pid_from] = nodes[from]
    [pid: pid_to] = nodes[to]
    GenServer.cast(pid_from, {:connect, pid_to})
  end
end
