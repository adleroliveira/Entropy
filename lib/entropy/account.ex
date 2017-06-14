defmodule Entropy.Account do
  use GenServer
  alias Entropy.Unit
  alias Entropy.Manager
  require Logger

  @die_after 1000 * 60 * 2 # 2 minutes

  defstruct [
    :id,
    :user_id,
    :balance,
    :color_filter,
    :number_filter,
    :color_change,
    :number_change,
    created: :os.system_time(:seconds),
    type: :user
  ]

  def new(color, number, :bank) do
    %__MODULE__{
      id: UUID.uuid4(),
      user_id: :bank,
      balance: :queue.new,
      color_filter: color,
      number_filter: number,
      color_change: Unit.get_rnd_color,
      number_change: Unit.get_rnd_number,
      type: :bank
    }
  end

  def new(user_id, color, number) do
    %__MODULE__{
      id: UUID.uuid4(),
      user_id: user_id,
      balance: :queue.new,
      color_filter: color,
      number_filter: number,
      color_change: Unit.get_rnd_color,
      number_change: Unit.get_rnd_number,
      type: :user
    }
  end

  def info(account) do
    GenServer.call(account, :info)
  end

  def release_unit(account) do
    GenServer.call(account, :release_unit)
  end

  def start_link(account) do
    GenServer.start_link(
      __MODULE__,
      [account],
      name: account.id |> String.to_atom
    )
  end

  def terminate(reason, _status) do
    IO.puts "Asked to stop because #{inspect reason}"
    :ok 
  end

  def init([account]) do
    if (account.type == :user), do: Process.send_after(self(), :die, @die_after)
    {:ok, account}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:release_unit, _from, state) do
    {:ok, unit, state} = case :queue.out(state.balance) do
      {:empty, _} -> {:error, "This bank account didn't have funds to release"}
      {{:value, unit}, balance} -> {:ok, unit, %{state | balance: balance}}
    end
    Manager.forward(transform_unit(unit, state), state.id |> String.to_atom)
    {:reply, :ok, state}
  end

  def handle_info({:unit, unit}, state) do
    state = cond do
      unit.color == state.color_filter and unit.number == state.number_filter ->
        Logger.debug "Account #{state.id} recieved a unit and added to its balance"
        %{ state | balance: :queue.in(unit, state.balance)}
      true ->
        Manager.forward(transform_unit(unit, state), state.id |> String.to_atom)
        Logger.debug "Account #{state.id} recieved a unit and forwarded"
        state
    end
    {:noreply, state}
  end

  def handle_info(:die, state) do
    :queue.to_list(state.balance)
    |> Enum.each(
      fn(unit) ->
        Manager.forward(
          transform_unit(unit, state),
          state.id |> String.to_atom)
      end)
    {:stop, :normal, state}
  end

  defp transform_unit(unit, state) do
    unit
    |> Unit.change_number(state.number_change)
    |> Unit.change_color(state.color_change)
  end

end