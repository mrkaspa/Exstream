defmodule Exstreme.GNode.Broadcast do
  use Exstreme.GNode.Behaviour

  # Broadcasts the message to the next nodes
  def handle_cast({:next, _, msg}, data) do
    {:ok, result} = data.func.(msg, data)
    send_next(self, data.next, result)
    {:noreply, data}
  end
end
