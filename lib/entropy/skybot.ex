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
    balance = User.get_balance(user.transactions)
    outstanding_acc = Bank.accounts_of(state.user) |> length
    cond do
      balance > Bank.account_price() ->
        :ok = buy_best_account_if_available(state)
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

  defp buy_best_account_if_available(state) do
    case best_account_choice() do
      {:error, :no_accounts_available} -> :ok
      {color, number} -> Bank.create_account(state.user, color, number)
    end
  end

  defp best_account_choice do
    case sorted_viable_accounts() do
      [{{color, number}, _amount} | _] -> {color, number}
      [] -> {:error, :no_accounts_available}
    end
  end

  def sorted_viable_accounts do
    Bank.info()
    |> Map.get(:accounts)
    |> Enum.filter(fn({_, balance}) -> balance > 0 end)
    |> Enum.sort(fn({_, b1}, {_, b2}) -> b1 > b2 end)
  end
end