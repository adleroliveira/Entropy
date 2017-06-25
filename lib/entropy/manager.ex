defmodule Entropy.Manager do
  use Supervisor
  alias Entropy.Account
  alias Entropy.Unit
  alias Entropy.Bank
  require Logger

  def create_account do
    Supervisor.start_child(__MODULE__, [])
  end

  def create_account(%Account{} = account) do
    Supervisor.start_child(__MODULE__, [account])
  end

  def create_unit(ammount \\ 1) do
    1..ammount
    |> Enum.each(fn(_) -> create_new_unit() end)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [worker(Account, [], restart: :transient)]
    supervise(children, strategy: :simple_one_for_one)
  end

  def accounts do
    list_accounts()
    |> Enum.map(&Account.info/1)
  end

  def send_to_random_account(unit) do
    account = Account.info(random_acount())
    account_process = account.id |> String.to_atom
    send_unit(account_process, unit)
  end

  def send_to_bank_account(unit) do
    Logger.debug "Sending unit of color: #{unit.color} and number #{unit.number} to bank account"
    Bank.accounts()
    |> Enum.find(
      fn(account) ->
        account.color == unit.color
        and account.number == unit.number
      end)
    |> Map.get(:id)
    |> String.to_atom
    |> send_unit(unit)
  end

  def forward(unit, from_account) do
    random_acount(from_account)
    |> send_unit(unit)
  end

  defp send_unit(account, unit) do
    Process.send(account, {:unit, unit}, [])
  end

  defp random_acount do
    {_, pid, _, _ } = Supervisor.which_children(__MODULE__) |> Enum.random()
    Process.info(pid)[:registered_name]
  end

  defp random_acount(account) do
    list_accounts()
    |> Enum.filter(fn(acc) -> acc != account end)
    |> Enum.random()
  end

  defp list_accounts do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn({_, pid, _, _}) -> Process.info(pid)[:registered_name] end)
  end

  defp create_new_unit do
    Unit.new |> send_to_random_account
  end
end