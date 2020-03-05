defmodule Counter.Store do
  use GenServer

  @topic "Counter.Store.value"

  # Convenience API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Counter.PubSub, @topic)
  end

  def curr() do
    GenServer.call(__MODULE__, :curr)
  end

  def incr(value \\ 1) do
    GenServer.call(__MODULE__, {:incr, value})
  end

  def decr(value \\ 1) do
    GenServer.call(__MODULE__, {:decr, value})
  end

  # GenServer implementation
  @impl true
  def init(_opts) do
    {:ok, %{current_value: 0}}
  end

  @impl true
  def handle_call(:curr, _from, %{current_value: current_value} = state) do
    {:reply, current_value, state}
  end

  @impl true
  def handle_call({:incr, value}, _from, %{current_value: current_value}) do
    new_value = current_value + value
    {:reply, new_value, %{current_value: new_value}, {:continue, :broadcast_value}}
  end

  @impl true
  def handle_call({:decr, value}, _from, %{current_value: current_value}) do
    new_value = current_value - value
    {:reply, new_value, %{current_value: new_value}, {:continue, :broadcast_value}}
  end

  @impl true
  def handle_continue(:broadcast_value, %{current_value: current_value} = state) do
    Phoenix.PubSub.broadcast(Counter.PubSub, @topic, {:current_value, current_value})
    {:noreply, state}
  end
end
