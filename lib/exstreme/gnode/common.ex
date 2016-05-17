defmodule Exstreme.GNode.Common do
  use Exstreme.GNode.Behaviour

  def handle_cast({:next, _, msg}, data) do
    {:ok, result} = data.func.(msg, data)
    send_next(self, data.next, result)
    {:noreply, data}
  end
end
