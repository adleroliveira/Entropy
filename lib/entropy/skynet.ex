defmodule Entropy.Skynet do
  use Supervisor
  alias Entropy.Skybot

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_bot do
    case Supervisor.start_child(__MODULE__, []) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      other -> other
    end
  end

  def init(:ok) do
    children = [worker(Skybot, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end
end