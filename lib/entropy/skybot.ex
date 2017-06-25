defmodule Entropy.Skybot do
  use GenServer
  alias Entropy.User
  alias Entropy.Bank
  require Logger

  def start_link() do
    botname = UUID.uuid4()
    User.create(botname, 123)
    GenServer.start_link(__MODULE__, [botname], name: botname |> String.to_atom)
  end

  def terminate(_reason, _status) do
    IO.puts "I'm a looser. Shutting down!"
    :ok 
  end

  def init([botname]) do
    bot = %{user: botname, max_reached: 0.0}
    Process.send_after(self(), :tick, 10000)
    {:ok, bot}
  end

  def handle_info(:tick, state) do
    Logger.debug "Tick"
    {:user, user} = User.get_user(state.user)
    balance = user |> Map.get(:balance)
    outstanding_acc = Bank.accounts_of(state.user) |> length
    IO.inspect {balance, Bank.account_price(), outstanding_acc}
    cond do
      balance > Bank.account_price() ->
        [{{color, number}, amount} | _] = Bank.info()
        |> Map.get(:accounts)
        |> Enum.filter(fn({_, balance}) -> balance > 0 end)
        |> Enum.sort(fn({_, b1}, {_, b2}) -> b1 > b2 end)
        Logger.warn "Best choice for account: #{color}, #{number} (#{amount})"
        Bank.create_account(state.user, color, number)
        if (balance >= 20) do
          Logger.warn "WINNNNNEEEEEER #{balance |> Float.to_string()}"
        else
          Process.send_after(self(), :tick, 10000)
        end
        {:noreply, :ok, state}
      true -> {:stop, :normal, state}
    end
  end
end