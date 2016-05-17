defmodule Exstreme.GNode.Broadcast do
  use Exstreme.GNode.Behaviour

  def handle_cast({:next, _, msg}, data) do
    send_next(self, data.next, msg)
    {:noreply, data}
  end
end
