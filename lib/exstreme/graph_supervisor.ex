defmodule Exstreme.GraphSupervisor do
  use Supervisor

  def start_link(graph) do
    pid =
      graph.name
      |> String.to_atom
      |> Process.whereis
    if pid != nil && Process.alive?(pid) do
      {:error, "The supervisor alredy exists"}
    else
      Supervisor.start_link(__MODULE__, graph, name: String.to_atom(graph.name))
    end
  end

  def init(graph) do
    children =
      Enum.map(graph.nodes, fn({gnode, params}) ->
        worker(Keyword.get(params, :module), [params], id: gnode)
      end)
    supervise(children, strategy: :one_for_one)
  end
end
