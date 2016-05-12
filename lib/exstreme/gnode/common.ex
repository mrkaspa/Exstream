defmodule Exstreme.GNode.Common do
  use Exstreme.GNode.Behaviour

  def handle_cast({:next, {_, msg} }, stats) do
    {:ok, result} = stats.func.(msg)
    send_next(stats.next, result)
  end
end
