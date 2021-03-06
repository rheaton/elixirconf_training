defmodule Docs.Counter do
  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value, name: :counter)
  end

  def init(initial_value) do
    # :timer.send_interval(2000, :tick)
    {:ok, initial_value}
  end

  def handle_cast(:inc, val) do
    {:noreply, val + 1}
  end
  def handle_cast(:dec, val) do
    {:noreply, val - 1}
  end
  # def handle_info(:tick, val) do
    # if val < 5, do: raise "NO"
    # {:noreply, val - 1}
  # end

  def inc(counter) do
    GenServer.cast(counter, :inc)
  end
  def dec(counter) do
    GenServer.cast(counter, :dec)
  end
  def val(counter) do
    GenServer.call(counter, :val)
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end
end
