defmodule Ping.Monitor.Watcher do
  use GenServer

  defmodule State do
    defstruct(
      url: nil,
      request_count: 0,
      frequency: 10_000,
      unresponsive_limit: 30,
      last_request_time: nil,
      last_response_time: nil,
      last_response_id: nil,
      status: :ok
    )
  end

  @spec start_link(Keyword.t) :: GenServer.on_start
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  def status?(pid), do: GenServer.call(pid, :status?)

  def init(opts) do
    state = %State{
      url: Keyword.get(opts, :url),
      frequency: Keyword.get(opts, :frequency, 10_000),
      unresponsive_limit: Keyword.get(opts, :unresponsive_limit, 30)
    }

    schedule_ping(state)

    {:ok, state}
  end

  def handle_call(:status?, _from, state) do
    if state.status == :ok && state.last_response_time &&
    DateTime.diff(DateTime.utc_now(), state.last_response_time) do
      {:reply, :available, state}
    else
      {:reply, :unavailable, state}
    end
  end

  def handle_info(:scheduled_ping, state) do
    self_pid = self
    ping_id = state.request_count + 1

    spawn(fn ->
      response = Ping.HTTP.ping(state.url)
      Process.send(self_pid, {:ping_response, ping_id, response}, [])
    end)

    state = Map.merge(state, %{
      request_count: ping_id,
      last_request_time: DateTime.utc_now()
    })

    schedule_ping(state)

    {:noreply, state}
  end

  def handle_info({:ping_response, ping_id, status}, state) do
    if !state.last_response_id || state.last_response_id < ping_id do
      state = Map.merge(state, %{
        status: status,
        last_response_id: ping_id,
        last_response_time: DateTime.utc_now()
      })

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def schedule_ping(state) do
    Process.send_after(self, :scheduled_ping, state.frequency)
  end
end
