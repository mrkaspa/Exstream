defmodule Exstreme.GNode.Funnel do
  use Exstreme.GNode.Behaviour

  # Receives a message and saves it in a messages map queue,
  # when all the messages are done sends a the map
  def handle_info({:on_next, from_data, msg}, data) do
    {result, new_queue} =
      data.funnel_queue
      |> add_queue(from_data.nid, msg)
      |> get_queue(data.opts[:before_nodes])
    send_message(result, data)
    {:noreply, update_in(data.funnel_queue, fn(_) -> new_queue end)}
  end


  #private

  # Sends the result to the next one
  defp send_message(result, data) do
    if result != nil do
      new_msg = Map.values(result)
      {:ok, result} = data.func.(new_msg, data)
      send_next(data.next, result)
    end
  end

  # Adds a message in the map queue
  defp add_queue(queue, from, msg) do
    idx = Enum.find_index(queue, &(!Map.has_key?(&1, from)))
    if idx != nil do
      List.update_at(queue, idx, &(Map.put(&1, from, msg)))
    else
      queue ++ [Map.new |> Map.put(from, msg)]
    end
  end

  # Gets a message from the map queue
  defp get_queue(queue = [head | tail], before_nodes) do
    before_nodes_set = MapSet.new(before_nodes)
    if MapSet.equal?(MapSet.new(Map.keys(head)), before_nodes_set) do
      {head, tail}
    else
      {nil, queue}
    end
  end
end
