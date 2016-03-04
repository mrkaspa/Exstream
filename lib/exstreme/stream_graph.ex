defmodule Exstreme.StreamGraph do
  @moduledoc """
  """
  defmodule Graph do
    defstruct params: [], nodes: %{}, connections: []
  end

  @doc """
  """
  def create_graph(params \\ []), do: %Graph{params: params}

  @doc """
  """
  def create_node(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_node_key(nodes)
    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  def add_connection(graph = %Graph{nodes: nodes}, start, finish) when start != finish do
    if Map.has_key?(nodes, start) and Map.has_key?(nodes, finish) do
      update_in(graph.connections, store_connection_fn(start, finish))
    else
      raise ArgumentError, message: "nodes not found"
    end
  end

  #private

  defp store_connection_fn(start, finish) do
    fn(connections) ->
      connections
      |> validate_repeated(start, finish)
      |> validate_repeated(finish, start)
      |> validate_position(start, :start)
      |> validate_position(finish, :end)
      |> Keyword.put(start, finish)
    end
  end

  def validate_repeated(connections, start, finish) do
    if connections |> Enum.any?(&(&1 == {start, finish})) do
      raise ArgumentError, message: "there is already a connection like that"
    else
      connections
    end
  end

  defp validate_position(connections, node, position) do
    case node|> Atom.to_string |> String.first do
      "n" -> validate_position_node(connections, node, position)
      # "b" ->
      # "f" ->
       _  -> raise ArgumentError, message: "invalid node"
    end
  end

  defp validate_position_node(connections, node, :start) do
    exist =
      connections
      |> Keyword.has_key?(node)
    if exist do
      raise ArgumentError, message: "the node can't be twice at start position"
    else
      connections
    end
  end

  defp validate_position_node(connections, node, :end) do
    exist =
      connections
      |> Keyword.values
      |> Enum.member?(node)
    if exist do
      raise ArgumentError, message: "the node can't be twice at end position"
    else
      connections
    end
  end

  defp next_node_key(nodes) do
    next_key(nodes, "n")
  end

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
