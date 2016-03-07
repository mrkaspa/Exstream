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
  def create_broadcast(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_broadcast_key(nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  def create_funnel(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_funnel_key(nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  """
  def add_connection(graph = %Graph{nodes: nodes}, start, finish) when start != finish do
    if has_node(nodes, start) && has_node(nodes, finish) do
      update_in(graph.connections, store_connection_fn(start, finish))
    end
  end

  #private

  defp store_connection_fn(start, finish) do
    fn(connections) ->
      add_connection = fn(keywords, start, finish) ->
        Keyword.update(keywords, start, finish, fn(value)->
          if is_list(value) do
            [finish | value]
          else
            [finish, value]
          end
        end)
      end

      connections
      |> validate_repeated(start, finish)
      |> validate_repeated(finish, start)
      |> validate_position(start, :start)
      |> validate_position(finish, :end)
      |> add_connection.(start, finish)
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
      "b" -> validate_position_broadcast(connections, node, position)
      "f" -> validate_position_funnel(connections, node, position)
       _  -> raise ArgumentError, message: "invalid node"
    end
  end

  defp validate_position_node(connections, node, :start) do
    validate_position_start(connections, node,"the node can't be twice at start position #{node}")
  end

  defp validate_position_node(connections, node, :end) do
    validate_position_end(connections, node,"the node can't be twice at end position")
  end

  defp validate_position_broadcast(connections, _, :start), do: connections

  defp validate_position_broadcast(connections, bct, :end) do
    validate_position_end(connections, bct, "the broadcast can't be twice at end position")
  end

  defp validate_position_funnel(connections, node, :start) do
    validate_position_start(connections, node,"the funnel can't be twice at start position #{node}")
  end

  defp validate_position_funnel(connections, node, :end), do: connections

  defp validate_position_start(connections, node, msg) do
    exist =
      connections
      |> Keyword.has_key?(node)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  defp validate_position_end(connections, node, msg) do
    exist =
      connections
      |> Keyword.values
      |> Enum.member?(node)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  defp has_node(nodes, node) do
    if Map.has_key?(nodes, node) do
      true
    else
      raise ArgumentError, message: "node #{node} not found"
    end
  end

  defp next_node_key(nodes) do
    next_key(nodes, "n")
  end

  defp next_broadcast_key(nodes) do
    next_key(nodes, "b")
  end

  defp next_funnel_key(nodes) do
    next_key(nodes, "f")
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
