defmodule Entropy.Bank do
  use GenServer
  alias Entropy.Unit
  alias Entropy.Account
  alias Entropy.Manager
  alias Entropy.User

  @account_price 1.00

  defstruct [
    accounts: [],
    currency: 0.00,
    units: 0
  ]

  def new do
    %__MODULE__{}
  end

  def accounts do
    GenServer.call(__MODULE__, :accounts)
  end

  def user_accounts do
    GenServer.call(__MODULE__, :user_accounts)
  end

  def accounts_of(username) do
    GenServer.call(__MODULE__, {:accounts_of, username})
  end

  def create_account(username, color, number) do
    GenServer.call(__MODULE__, {:new_account, username, color, number})
  end

  def create_unit(ammount \\ 1) do
    GenServer.call(__MODULE__, {:create_units, ammount})
  end

  def info do
    GenServer.call(__MODULE__, :info)
  end

  def payout(user_id, amount) do
    GenServer.call(__MODULE__, {:payout, user_id, amount})
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def account_price do
    @account_price
  end

  def init(_) do
    bank = __MODULE__.new
    accounts = for color <- Unit.colors, number <- Unit.numbers do
      account = Account.new(color, number, :bank)
      {:ok, _pid} = Manager.create_account(account)
      account.id |> String.to_atom
    end
    account_ids = accounts
    {:ok, %{bank | accounts: account_ids}}
  end

  def handle_call(:accounts, _from, state) do
    accounts = get_accounts(state)
    {:reply, accounts, state}
  end

  def handle_call(:user_accounts, _from, state) do
    user_accounts =
      Manager.accounts
      |> Enum.filter(fn(account) -> account.type == :user end)
    {:reply, user_accounts, state}
  end

  def handle_call({:accounts_of, username}, _from, state) do
    case User.from_username(username) do
      {:error, :not_found} ->
        {:reply, {:error, :user_not_found}, state}
      {Users, user_id, _, _, _} ->
        accounts = Manager.accounts
        |> Enum.filter(fn(account) -> account.user_id == user_id end)
        {:reply, accounts, state}
    end
  end

  def handle_call({:new_account, username, color, number}, _from, state) do
    case User.from_username(username) do
      {:error, :not_found} -> {:reply, {:error, "Invalid User"}, state}
      {Users, user_id, _, _, _} -> new_account(user_id, color, number, state)
    end
  end

  def handle_call({:payout, user_id, amount}, _from, state) do
    value = get_unit_value(state) |> Kernel.*(amount)
    User.credit(user_id, value, "payout")
    {:reply, :ok, %{state | currency: state.currency - value}}
  end

  def handle_call({:create_units, ammount}, _from, state) do
    Manager.create_unit(ammount)
    {:reply, :ok, %{state | units: state.units + ammount}}
  end

  def handle_call(:info, _from, state) do
    summary = accounts_summary(state)
    units_on_bank = summary
    |> Enum.reduce(0, fn({{_, _}, num}, total) -> total + num end)
    info = %{
      balance: state.currency,
      total_units: state.units,
      unit_value: get_unit_value(state),
      accounts: summary,
      units_on_bank_accounts: units_on_bank
    }
    {:reply, info, state}
  end

  def export(%{:accounts => accounts} = bank_info) do
    transformed = accounts
    |> Enum.sort(fn({_, b1}, {_, b2}) -> b1 > b2 end)
    |> Enum.map(
      fn({{color, number}, amount}) ->
        %{
          color: color,
          number: number,
          amount: amount
        }
      end)
    bank_info |> Map.put(:accounts, transformed)
  end

  defp get_unit_value(state) do
    cond do
      state.units > 0 -> state.currency / state.units
      true -> 0
    end
  end

  defp new_account(user_id, color, number, state) do
    case Unit.valid?({color, number}) do
      true ->
        bank_account = get_account(color, number, state)
        case account_balance(bank_account) do
          0 -> {:reply, {:error, "Not enough funds"}, state}
          _ ->
            case User.debit(user_id, @account_price, "account purchase") do
              :ok ->
                {:ok, _pid} = Manager.create_account(Account.new(user_id, color, number))
                Account.release_unit(bank_account.id |> String.to_atom)
                {:reply, :ok, %{state | currency: state.currency + @account_price}}
              other -> {:reply, other, state}
            end
        end
      _ -> {:reply, {:error, :invalid_unit}, state}
    end
  end

  defp accounts_summary(state) do
    get_accounts(state)
    |> Enum.map(
      fn(account) ->
        {{account.color, account.number}, account_balance(account)}
      end)
  end

  defp account_balance(account) do
    :queue.len(account.balance)
  end

  defp get_accounts(state) do
    state.accounts |> Enum.map(&Account.info/1)
  end

  defp get_account(color, number, state) do
    [account] = state.accounts
    |> Enum.map(&Account.info/1)
    |> Enum.filter(
      fn(account) ->
        account.color == color
        and account.number == number
      end)
    account
  end
end