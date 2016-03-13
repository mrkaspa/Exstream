defmodule Exstreme.Graph do
  @moduledoc """
  """
  alias __MODULE__

  @type t :: %Graph{params: [key: term], nodes: %{key: atom}, connections: %{key: atom}}
  defstruct params: [], nodes: %{}, connections: %{}

  @doc """
  """
  @spec count_nodes(t) :: non_neg_integer
  def count_nodes(%Graph{nodes: nodes}) do
    nodes
    |> Map.keys
    |> Enum.count
  end

  @doc """
  """
  @spec count_connections(t) :: non_neg_integer
  def count_connections(%Graph{connections: connections}) do
    connections
    |> Map.keys
    |> Enum.count
  end

  @doc """
  """
  @spec connections_stats(t) :: %{key: integer}
  def connections_stats(graph) do
    graph
    |> map_to_connections
    |> Enum.reduce(Map.new, fn(key, map) ->
        Map.update(map, key, 1, &(&1 + 1))
      end)
  end

  @doc """
  """
  @spec find_start_node(t) :: [atom]
  def find_start_node(%Graph{nodes: nodes, connections: connections}) do
    is_first? =
      fn(node) ->
        at_first?(connections, node) and not(at_last?(connections, node))
      end

    nodes
    |> Map.keys
    |> Enum.filter(is_first?)
  end

  # private

  @spec map_to_connections(t) :: [atom]
  defp map_to_connections(%Graph{nodes: nodes, connections: connections}) do
    to_connections =
      fn(node) ->
        case {at_first?(connections, node), at_last?(connections, node)} do
          {true, true}   -> :connected
          {true, false}  -> :begin
          {false, true}  -> :end
          {false, false} -> :unconnected
        end
      end

    nodes
    |> Map.keys
    |> Enum.map(to_connections)
  end

  @spec at_first?(%{key: atom}, atom) :: boolean
  defp at_first?(connections,  node) do
    Map.has_key?(connections, node)
  end

  @spec at_last?(%{key: atom}, atom) :: boolean
  defp at_last?(connections,  node) do
    connections
    |> Map.values
    |> List.flatten
    |> Enum.member?(node)
  end
end
