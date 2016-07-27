defmodule Exstreme.GraphValidator do
  alias Exstreme.Graph
  @moduledoc """
  Contains the functions to validate a graph
  """

  @typedoc """
  Validation error
  """
  @type error :: {:error, String.t}

  @doc """
  Ensures the Graph is valid
  """
  @spec validate(Graph.t) :: :ok | error
  def validate(graph) do
    with :ok <- validate_must_have_connections(graph),
         :ok <- validate_start_nodes(graph),
         :ok <- validate_connectivity(graph),
    do: :ok
  end

  # private

  # Validates that the Graph is not empty
  @spec validate_must_have_connections(Graph.t) :: :ok | error
  defp validate_must_have_connections(graph) do
    nodes_amount = Graph.count_nodes(graph)
    connections_amount = Graph.count_connections(graph)
    if nodes_amount > 0 and connections_amount == 0 do
      {:error, ""}
    else
      :ok
    end
  end

  # Validates it must have just one start node and must be a common one
  @spec validate_start_nodes(Graph.t) :: :ok | error
  defp validate_start_nodes(graph) do
    start_nodes = Graph.find_start_node(graph)

    with :ok <- validate_should_start_with_one_node(start_nodes),
         :ok <- validate_should_start_with_node(start_nodes),
    do: :ok
  end

  # Validates it must have just one start node
  @spec validate_should_start_with_one_node([atom, ...]) :: :ok | error
  defp validate_should_start_with_one_node([_]), do: :ok

  defp validate_should_start_with_one_node(_), do: {:error, ""}

  # The start node must be a common one
  @spec validate_should_start_with_node([atom, ...]) :: :ok | error
  defp validate_should_start_with_node([start_node]) do
    start_char = start_node |> Atom.to_string |> String.first
    if start_char == "n" do
      :ok
    else
      {:error, ""}
    end
  end

  # The Graph is connected
  @spec validate_connectivity(Graph.t) :: :ok | error
  defp validate_connectivity(graph) do
    stats = Graph.connections_stats(graph)
    if stats[:unconnected] == nil do
      :ok
    else
      {:error, ""}
    end
  end
end
