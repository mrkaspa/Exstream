defmodule Exstreme.Gnode.Behaviour do
  @moduledoc """
  """

  defmodule Data do
    @moduledoc """
    """
    alias __MODULE__

    @type t :: %Data{next: [pid], pid: pid, func: (term) -> no_return, opts: [key: term]}
    defstruct [next: [], pid: nil, func: nil, opts: []]
  end

  def __using__ do
    quote do
      use GenServer
      alias Exstreme.Gnode.Behaviour.Data

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
      end

      def init(params = [func: func]) do
        opts = Keyword.drop(params, [:func, :type])
        {:ok, %Data{func: func, pid: self, opts: opts}}
      end

      def handle_cast({:connect, to_pid}, data) do
        new_data = update_in(data.next, fn(next) -> [pid | next] end)
        {:noreply, new_data}
      end

      def send_next(next, msg) do
        Enum.each(next, fn(pid) ->
          GenServer.cast(pid, msg)
        do)
      end
    end
  end
end
