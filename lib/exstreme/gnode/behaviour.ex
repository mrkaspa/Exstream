defmodule Exstreme.GNode.Behaviour do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      use GenServer
      import Exstreme.GNode.Behaviour
    end
  end

  defmodule Data do
    @moduledoc """
    """
    alias __MODULE__

    @type graph_func :: ((term, Data.t) -> {:ok, term} | :error)

    @type t :: %Data{next: [pid], pid: pid, nid: atom, func: graph_func, funnel_queue: [term], received_counter: non_neg_integer, sent_counter: non_neg_integer, opts: [key: term]}
    defstruct [next: [], pid: nil, nid: nil, func: nil, funnel_queue: [], received_counter: 0, sent_counter: 0, opts: []]

    #TODO use counters
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(params = [func: func, nid: nid]) do
    opts = Keyword.drop(params, [:func, :type, :nid])
    {:ok, %Data{func: func, pid: self, nid: nid, opts: opts}}
  end

  def handle_cast({:connect, to_pid}, data) do
    new_data = update_in(data.next, fn(next) -> [to_pid | next] end)
    {:noreply, new_data}
  end

  def handle_cast({:send_next, next, msg}, data) do
    Enum.each(next, &(GenServer.cast(&1, {:next, self, msg})))
    {:noreply, data}
  end

  def send_next(pid, next, msg) do
    GenServer.cast(pid, {:send_next, next, msg})
  end
end
