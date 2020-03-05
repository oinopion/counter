defmodule CounterWeb.CounterLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    Counter.Store.subscribe()
    counter_value = Counter.Store.curr()
    {:ok, assign_value(socket, counter_value)}
  end

  def render(assigns) do
    ~L"""
    Current counter value: <%= @current_value %>
    </br>
    <button phx-click="incr">+</button>
    <button phx-click="decr">-</button>
    """
  end

  def handle_event("incr", _value, socket) do
    new_value = Counter.Store.incr()
    {:noreply, assign_value(socket, new_value)}
  end

  def handle_event("decr", _value, socket) do
    new_value = Counter.Store.decr()
    {:noreply, assign_value(socket, new_value)}
  end

  def handle_info({:current_value, current_value}, socket) do
    {:noreply, assign_value(socket, current_value)}
  end

  defp assign_value(socket, value) do
    assign(socket, :current_value, value)
  end
end
