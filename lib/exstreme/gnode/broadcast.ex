defmodule Exstreme.GNode.Broadcast do
  use Exstreme.GNode.Behaviour

  def handle_cast({:next, {_, msg}}, stats) do
    send_next(stats.next, msg)
  end
end
