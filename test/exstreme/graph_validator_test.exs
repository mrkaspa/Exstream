defmodule Exstreme.GraphValidatorTest do
  use ExUnit.Case
  use Exstreme.Common
  alias Exstreme.GraphValidator
  doctest Exstreme.GraphValidator

  test "the graph with many nodes must be valid" do
    assert :ok = GraphValidator.validate(graph_many_nodes)
  end

  test "the graph with one gnode must be invalid" do
    assert {:error, _} = GraphValidator.validate(graph_one_node_no_connections)
  end

  test "the graph without connections is invalid" do
    assert {:error, _} = GraphValidator.validate(graph_no_connections)
  end

  test "the graph should start in a gnode" do
    assert {:error, _} = GraphValidator.validate(graph_start_with_broadcast)
    assert {:error, _} = GraphValidator.validate(graph_start_with_funnnel)
  end

  test "all the nodes in the graph has to be connected" do
    assert {:error, _} = GraphValidator.validate(graph_unconnected_nodes)
  end
end
