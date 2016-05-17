defmodule Exstreme.GNode.Funnel do
  use Exstreme.GNode.Behaviour

  def handle_cast({:next, from_data, msg}, data) do
    {res, new_queue} =
      data.funnel_queue
      |> add_queue(from_data.nid, msg)
      |> get_queue(data.opts[:before_nodes])
    send_message(res, data.next)
    {:noreply, update_in(data.funnel_queue, new_queue)}
  end

  #private

  defp send_message(res, next) do
    if res != nil do
      new_msg =
        res
        |> Map.values
        |> List.to_tuple
      send_next(self, next, new_msg)
    end
  end

  defp add_queue(queue, from, msg) do
    idx = Enum.find_index(queue, &(!Map.has_key?(&1, from)))
    if idx != nil do
      List.update_at(queue, idx, &(Map.put(&1, from, msg)))
    else
      [queue | Map.new |> Map.put(from, msg)]
    end
  end

  defp get_queue(queue = [head | tail], before_nodes) do
    before_nodes_set = MapSet.new(before_nodes)
    if MapSet.equal?(MapSet.new(Map.keys(head)), before_nodes_set) do
      {head, tail}
    else
      {nil, queue}
    end
  end
end
