defmodule Exstreme.GNode.Broadcast do
  use Exstreme.GNode.Behaviour

  # Broadcasts the message to the next nodes
  def handle_info({:on_next, _, msg}, data) do
    {:ok, result} = data.func.(msg, data)
    send_next(data.next, result)
    {:noreply, data}
  end
end
