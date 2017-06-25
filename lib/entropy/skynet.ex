defmodule Entropy.Skynet do
  use Supervisor
  alias Entropy.Skybot

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_bot do
    Supervisor.start_child(__MODULE__, [])
  end

  def init(:ok) do
    children = [worker(Skybot, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end
end