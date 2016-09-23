defmodule Exstreme.Graph do
  @moduledoc """
  This module contains useful functions to get information about a graph.
  """
  alias __MODULE__

  @typedoc """
  Represents the Graph data
  """
  @type t :: %Graph{name: String.t, params: [key: term], nodes: %{key: [key: term]}, connections: %{key: atom}}
  defstruct name: '', params: [], nodes: %{}, connections: %{}

  @doc """
  Counts the Graph nodes
  """
  @spec count_nodes(t) :: non_neg_integer
  def count_nodes(%Graph{nodes: nodes}) do
    nodes
    |> Map.keys
    |> Enum.count
  end

  @doc """
  Counts the connections
  """
  @spec count_connections(t) :: non_neg_integer
  def count_connections(%Graph{connections: connections}) do
    connections
    |> Map.values
    |> List.flatten
    |> Enum.count
  end

  @doc """
  Counts the connected, unconnected, begin and end nodes
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
  Gets the starting gnode
  """
  @spec find_start_node(t) :: [atom]
  def find_start_node(%Graph{nodes: nodes, connections: connections}) do
    is_first? =
      fn(gnode) ->
        at_first?(connections, gnode) and not(at_last?(connections, gnode))
      end

    nodes
    |> Map.keys
    |> Enum.filter(is_first?)
  end

  @doc """
  Gets the last nodes
  """
  @spec find_last_node(t) :: [atom]
  def find_last_node(%Graph{nodes: nodes, connections: connections}) do
    is_last? =
      fn(gnode) ->
        not(at_first?(connections, gnode)) and at_last?(connections, gnode)
      end

    nodes
    |> Map.keys
    |> Enum.filter(is_last?)
  end

  @doc """
  Gets the nodes before the current one
  """
  @spec get_before_nodes(t, atom) :: [atom]
  def get_before_nodes(%Graph{connections: connections}, gnode) do
    compare_func =
      fn(current_node, {from, to}) ->
        {current_node == to, from}
      end

    connections
    |> Enum.reduce([], fn(connection, res) ->
        List.flatten(get_nodes_func(gnode, connection, res, compare_func), res)
      end)
    |> Enum.uniq
  end

  @doc """
  Gets the nodes after the current one
  """
  @spec get_after_nodes(t, atom) :: [atom]
  def get_after_nodes(%Graph{connections: connections}, gnode) do
    compare_func =
      fn(current_node, {from, to}) ->
        {current_node == from, to}
      end

    connections
    |> Enum.reduce([], fn(connection, res) ->
        res ++ get_nodes_func(gnode, connection, res, compare_func)
      end)
    |> Enum.uniq
  end

  @doc """
  Gets the name in the Graph for one gnode
  """
  @spec nid(t, atom) :: atom
  def nid(%Graph{name: name}, gnode) do
    [char, rest] =
      gnode
      |> Atom.to_string
      |> String.codepoints
    String.to_atom("#{char}_#{name}_#{rest}")
  end

  # private

  # Map the connections to the kind of connection
  @spec map_to_connections(t) :: [atom]
  defp map_to_connections(%Graph{nodes: nodes, connections: connections}) do
    to_connections =
      fn(gnode) ->
        case {at_first?(connections, gnode), at_last?(connections, gnode)} do
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

  # Checks if a gnode is the first position of a connection
  @spec at_first?(%{key: atom}, atom) :: boolean
  defp at_first?(connections, gnode) do
    Map.has_key?(connections, gnode)
  end

  # Checks if a gnode is the last position of a connection
  @spec at_last?(%{key: atom}, atom) :: boolean
  defp at_last?(connections,  gnode) do
    connections
    |> Map.values
    |> List.flatten
    |> Enum.member?(gnode)
  end

  @spec get_nodes_func(atom, {atom, atom}, [atom], ((atom, {atom, atom}) -> boolean)) :: [atom]
  defp get_nodes_func(gnode, {from, to} = pair, res, func) do
    case to do
      to when is_atom(to) ->
        {ok, add_node} = func.(gnode, pair)
        if ok do
          [add_node | res]
        else
          res
        end
      to when is_list(to) ->
        Enum.reduce(to, res, fn(current_to, new_res) ->
          List.flatten(get_nodes_func(gnode, {from, current_to}, new_res, func), new_res)
        end)
    end
  end
end
