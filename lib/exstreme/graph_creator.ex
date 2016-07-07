defmodule Exstreme.GraphCreator do
  @moduledoc """
  Creates a Graph representation
  """
  alias Exstreme.Graph

  @default_length_name 20

  @typedoc """
  
  """
  @type update_map_func :: (%{key: atom} -> %{key: atom})

  @doc """
  Creates a Graph generating a name
  """
  @spec create_graph([key: term]) :: Graph.t
  def create_graph(params) do
    name =
        @default_length_name
        |> :crypto.strong_rand_bytes
        |> Base.url_encode64
        |> binary_part(0, @default_length_name)
    create_graph(name, params)
  end

  @doc """
  Creates a Graph with a given name
  """
  @spec create_graph(String.t, [key: term]) :: Graph.t
  def create_graph(name, params), do: %Graph{name: name, params: params}

  @doc """
  Creates a simple gnode
  """
  @spec create_node(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_node(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_node_key(graph, nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  Creates a broadcast gnode
  """
  @spec create_broadcast(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_broadcast(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_broadcast_key(graph, nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  Creates a funnel gnode
  """
  @spec create_funnel(Graph.t, [key: term]) :: {Graph.t, atom}
  def create_funnel(graph = %Graph{nodes: nodes}, params \\ []) do
    key = next_funnel_key(graph, nodes)

    new_graph = update_in(graph.nodes, &(Map.put(&1, key, params)))
    {new_graph, key}
  end

  @doc """
  Adds a connection between two nodes
  """
  @spec add_connection(Graph.t, atom, atom) :: Graph.t
  def add_connection(graph = %Graph{nodes: nodes}, start, finish) do
    if start !== finish do
      if validate_node_exist(nodes, start) and validate_node_exist(nodes, finish)    do
        update_in(graph.connections, store_connection_fn(start, finish))
      end
    else
      raise ArgumentError, message: "You can't connect to the same gnode"
    end
  end

  # private

  # Adds a connection to the connections map
  @spec store_connection_fn(atom, atom) :: update_map_func
  defp store_connection_fn(start, finish) do
    fn(connections) ->
      add_connection = fn(keywords, start, finish) ->
        Map.update(keywords, start, finish, fn
          (value) when is_list(value) ->
            [finish | value]
          (value) ->
            [finish, value]
        end)
      end

      # validates before adding
      connections
      |> validate_position(start, :start)
      |> validate_position(finish, :end)
      |> validate_repeated(start, finish)
      |> validate_repeated(finish, start)
      |> add_connection.(start, finish)
    end
  end

  # validations before adding a gnode

  # Validates when a relation already exists
  @spec validate_repeated(%{key: atom}, atom, atom) :: %{key: atom}
  defp validate_repeated(connections, start, finish) do
    validate = fn
      ({key, list}) when is_list(list) ->
        key == start && Enum.member?(list, finish)
      (connection) ->
        connection == {start, finish}
      end

    if Enum.any?(connections, validate) do
      raise ArgumentError, message: "there is already a connection like that"
    else
      connections
    end
  end

  # Validates the gnode position
  @spec validate_position(%{key: atom}, atom, :start | :end) :: %{key: atom}
  defp validate_position(connections, gnode, position) do
    case gnode |> Atom.to_string |> String.first do
      "n" -> validate_position_node(connections, gnode, position)
      "b" -> validate_position_broadcast(connections, gnode, position)
      "f" -> validate_position_funnel(connections, gnode, position)
       _  -> raise ArgumentError, message: "invalid gnode"
    end
  end

  # Validates if a normal gnode can be at the beginning of the relation
  @spec validate_position_node(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_node(connections, gnode, :start) do
    validate_position_start(connections, gnode,"the gnode can't be twice at start position #{gnode}")
  end

  # Validates if a normal gnode can be at the end of the relation
  @spec validate_position_node(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_node(connections, gnode, :end) do
    validate_position_end(connections, gnode,"the gnode can't be twice at end position")
  end

  # Validates if a broadcast gnode can be at the beginning of the relation
  @spec validate_position_broadcast(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_broadcast(connections, _node, :start), do: connections

  # Validates if a broadcast gnode can be at the end of the relation
  @spec validate_position_broadcast(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_broadcast(connections, bct, :end) do
    validate_position_end(connections, bct, "the broadcast can't be twice at end position")
  end

  # Validates if a funnel gnode can be at the beginning of the relation
  @spec validate_position_funnel(%{key: atom}, atom, :start) :: %{key: atom}
  defp validate_position_funnel(connections, gnode, :start) do
    validate_position_start(connections, gnode,"the funnel can't be twice at start position #{gnode}")
  end

  # Validates if a funnel gnode can be at the normal of the relation
  @spec validate_position_funnel(%{key: atom}, atom, :end) :: %{key: atom}
  defp validate_position_funnel(connections, _node, :end), do: connections

  @spec validate_position_start(%{key: atom}, atom, String.t) :: %{key: atom}
  defp validate_position_start(connections, gnode, msg) do
    exist = Map.has_key?(connections, gnode)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  @spec validate_position_end(%{key: atom}, atom, String.t) :: %{key: atom}
  defp validate_position_end(connections, gnode, msg) do
    exist =
      connections
      |> Map.values
      |> Enum.member?(gnode)
    if exist do
      raise ArgumentError, message: msg
    else
      connections
    end
  end

  # Validates the gnode exist on the graph
  @spec validate_node_exist(%{key: [key: term]}, atom) :: true
  defp validate_node_exist(nodes, gnode) do
    if Map.has_key?(nodes, gnode) do
      true
    else
      raise ArgumentError, message: "gnode #{gnode} not found"
    end
  end

  # Gets the next key for the gnode, these begin with the 'n' letter
  @spec next_node_key(Graph.t, %{key: atom}) :: atom
  defp next_node_key(graph, nodes) do
    next_key(graph, nodes, "n")
  end

  # Gets the next key for the broadcast, these begin with the 'b' letter
  @spec next_broadcast_key(Graph.t, %{key: atom}) :: atom
  defp next_broadcast_key(graph, nodes) do
    next_key(graph, nodes, "b")
  end

  # Gets the next key for the funnel, these begin with the 'f' letter
  @spec next_funnel_key(Graph.t, %{key: atom}) :: atom
  defp next_funnel_key(graph, nodes) do
    next_key(graph, nodes, "f")
  end

  # Gets the next key according to the given letter
  @spec next_key(Graph.t, %{key: atom}, String.t) :: atom
  defp next_key(graph, map, letter) do
    count =
      map
      |> Map.keys
      |> Enum.map(&Atom.to_string/1)
      |> Enum.filter(&(String.starts_with?(&1, letter)))
      |> Enum.count
    Graph.nid(graph, String.to_atom("#{letter}#{count + 1}"))
  end
end
