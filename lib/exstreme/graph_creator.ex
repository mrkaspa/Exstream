defmodule Exstreme.GraphCreator do
  @moduledoc """
  """
  alias Exstreme.Graph

  @type update_map_func :: (%{key: atom} -> %{key: atom})

  @doc """
  """
  @spec create_graph([key: term]) :: Graph.t
  def create_graph(params \\ []), do: %Graph{params: params}

  @doc """
  """
  @spec create_node(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_node(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_node_key(nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  @spec create_broadcast(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_broadcast(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_broadcast_key(nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  @spec create_funnel(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_funnel(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_funnel_key(nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  @spec add_connection(Graph.t, atom, atom) :: Graph.t
  def add_connection(graph = %Graph{nodes: nodes}, start, finish) when start !== finish do
    if has_node(nodes, start) and has_node(nodes, finish)    do
      update_in(graph.connections, store_connection_fn(start, finish))
    end
  end

  # private

  @spec store_connection_fn(atom, atom) :: update_map_func
  defp store_connection_fn(start, finish) do
    fn(connections) ->
      add_connection = fn(keywords, start, finish) ->
        Map.update(keywords, start, finish, fn(value)->
          if is_list(value) do
            [finish | value]
          else
            [finish, value]
          end
        end)
      end

      # validates before adding
      connections
      |> validate_repeated(start, finish)
      |> validate_repeated(finish, start)
      |> validate_position(start, :start)
      |> validate_position(finish, :end)
      |> add_connection.(start, finish)
    end
  end

  # validations before adding a node

  @spec validate_repeated(%{key: atom}, atom, atom) :: %{key: atom}
  defp validate_repeated(connections, start, finish) do
    if Enum.any?(connections, &(&1 == {start, finish})) do
      raise ArgumentError, message: "there is already a connection like that"
    else
      connections
    end
  end

  @spec validate_position(%{key: atom}, atom, :start | :end) :: %{key: atom}
  defp validate_position(connections, node, position) do
    case node |> Atom.to_string |> String.first do
      "n" -> validate_position_node(connections, node, position)
      "b" -> validate_position_broadcast(connections, node, position)
      "f" -> validate_position_funnel(connections, node, position)
       _  -> raise ArgumentError, message: "invalid node"
    end
  end

  @spec validate_position_node(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_node(connections, node, :start) do
    validate_position_start(connections, node,"the node can't be twice at start position #{node}")
  end

  @spec validate_position_node(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_node(connections, node, :end) do
    validate_position_end(connections, node,"the node can't be twice at end position")
  end

  @spec validate_position_broadcast(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_broadcast(connections, _node, :start), do: connections

  @spec validate_position_broadcast(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_broadcast(connections, bct, :end) do
    validate_position_end(connections, bct, "the broadcast can't be twice at end position")
  end

  @spec validate_position_funnel(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_funnel(connections, node, :start) do
    validate_position_start(connections, node,"the funnel can't be twice at start position #{node}")
  end

  @spec validate_position_funnel(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_funnel(connections, _node, :end), do: connections

  @spec validate_position_start(%{key: atom}, atom, String.t) :: %{key: atom}
  defp validate_position_start(connections, node, msg) do
    exist = Map.has_key?(connections, node)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  @spec validate_position_end(%{key: atom}, atom, String.t) :: %{key: atom}
  defp validate_position_end(connections, node, msg) do
    exist =
      connections
      |> Map.values
      |> Enum.member?(node)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  @spec has_node(%{key: atom}, atom) :: true
  defp has_node(nodes, node) do
    if Map.has_key?(nodes, node) do
      true
    else
      raise ArgumentError, message: "node #{node} not found"
    end
  end

  @spec next_node_key(%{key: atom}) :: atom
  defp next_node_key(nodes) do
    next_key(nodes, "n")
  end

  @spec next_broadcast_key(%{key: atom}) :: atom
  defp next_broadcast_key(nodes) do
    next_key(nodes, "b")
  end

  @spec next_funnel_key(%{key: atom}) :: atom
  defp next_funnel_key(nodes) do
    next_key(nodes, "f")
  end

  @spec next_key(%{key: atom}, String.t) :: atom
  defp next_key(map, letter) do
    count =
      map
      |> Map.keys
      |> Enum.map(&Atom.to_string/1)
      |> Enum.filter(fn(str) -> String.starts_with?(str, letter) end)
      |> Enum.count
    String.to_atom("#{letter}#{count + 1}")
  end
end
