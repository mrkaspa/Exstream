defmodule Exstreme.GNode.Common do
  use Exstreme.GNode.Behaviour

  # Sends the result to the next one
  def handle_info({:on_next, _, msg}, data) do
    {:ok, result} = data.func.(msg, data)
    send_next(data.next, result)
    {:noreply, data}
  end
end
