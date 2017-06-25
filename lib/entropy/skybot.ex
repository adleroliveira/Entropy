defmodule Entropy.Skybot do
  use GenServer
  alias Entropy.User
  alias Entropy.Bank
  alias Entropy.Utils
  require Logger

  def start_link() do
    botname = Utils.generate_name()
    User.create(botname, 123)
    GenServer.start_link(__MODULE__, [botname], name: botname |> String.to_atom)
  end

  def terminate(_reason, _status) do
    IO.puts "I'm a looser. Shutting down!"
    :ok 
  end

  def tick(pid) do
    GenServer.cast(pid, :tick)
  end

  def init([botname]) do
    Process.send_after(self(), :tick, 10000)
    IO.inspect "BOT #{botname} INITIATED"
    {:ok, %{user: botname, max_reached: 0.0}}
  end

  def handle_info(:tick, state) do
    play(state)
  end

  def handle_cast(:tick, state) do
    play(state)
  end

  defp play(state) do
    {:user, user} = User.get_user(state.user)
    balance = user |> Map.get(:balance)
    outstanding_acc = Bank.accounts_of(state.user) |> length
    cond do
      balance > Bank.account_price() ->
        [{{color, number}, _amount} | _] = Bank.info()
        |> Map.get(:accounts)
        |> Enum.filter(fn({_, balance}) -> balance > 0 end)
        |> Enum.sort(fn({_, b1}, {_, b2}) -> b1 > b2 end)
        Bank.create_account(state.user, color, number)
        if (balance >= 20) do
          Logger.warn "WINNNNNEEEEEER #{balance |> Float.to_string()}"
        else
          Process.send_after(self(), :tick, 10000)
        end
        {:noreply, state}
      true ->
        cond do
          outstanding_acc > 0 ->
            Process.send_after(self(), :tick, 10000)
            {:noreply, state}
          true -> {:stop, :normal, state}
        end
    end
  end
end