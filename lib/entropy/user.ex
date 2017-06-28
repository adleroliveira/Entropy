defmodule Entropy.User do
  import Comeonin.Bcrypt
  alias Entropy.Transaction

  defstruct [
    :id,
    :username,
    :password_hash,
    transactions: []
  ]

  def new(username, password) do
    %__MODULE__{
      id:             UUID.uuid4(),
      username:       username,
      password_hash:  hashpwsalt(password),
      transactions:   [Transaction.amend(:credit, 10.00, "Initial Credit")]
    }
  end

  def create(user, pass) do
    case get_user_from_username(user) do
      {:atomic, []} ->
        new(user, pass |> Kernel.to_string()) |> save
      _other -> {:error, "User already exists"}
    end
  end

  def create_table do
    case :mnesia.create_table(Users, [
      type: :set,
      attributes: [:id, :username, :password_hash, :transactions],
      disc_copies: [node()]
    ]) do
      {:atomic, :ok} ->
        IO.puts "[Users] table created successfuly."
        :ok
      {:aborted, {:already_exists, _table}} ->
        IO.puts "Table Users already exists"
        :ok
      {:aborted, reason} ->
        IO.puts reason
        {:error, reason}
    end
  end

  def get_user(id_or_username) do
    case get_user_from_id(id_or_username) do
      {:atomic, [user_record]} -> {:user, from_record(user_record)}
      _ ->
        case get_user_from_username(id_or_username) do
          {:atomic, [user_record]} -> {:user, from_record(user_record)}
          _ -> {:error, :not_found}
        end
    end
  end

  def credit(id_or_username, amount, reason \\ "add funds") do
    case get_user(id_or_username) do
      {:user, user} ->
        user
        |> Map.put(:transactions, [Transaction.credit(amount, reason) | user.transactions])
        |> save()
      other -> other
    end
  end

  def debit(id_or_username, amount, reason \\ "deduct funds") do
    case get_user(id_or_username) do
      {:user, user} ->
        balance = get_balance(user.transactions)
        deduct_if_available(user, balance, amount, reason)
      other -> other
    end
  end

  def get_balance(transactions) do
    transactions
    |> Enum.sort(&(&1.timestamp > &2.timestamp))
    |> Enum.reduce(0.00,
      fn(transaction, total) ->
        case transaction.type do
          :credit -> total + transaction.amount
          :debit  -> total - transaction.amount
        end
      end)
  end

  def get_investment(transactions) do
    transactions
    |> Enum.filter(&(&1.type == :debit and &1.investment == true))
    |> Enum.reduce(0.00, fn(trx, total) -> total + trx.amount end)
  end

  def get_return(transactions) do
    transactions
    |> Enum.filter(&(&1.type == :credit and &1.return == true))
    |> Enum.reduce(0.00, fn(trx, total) -> total + trx.amount end)
  end

  def deduct_if_available(user, balance, amount, reason) when balance >= amount do
    user
    |> Map.put(:transactions, [Transaction.debit(amount, reason) | user.transactions])
    |> save()
  end

  def deduct_if_available(_user, _balance, _amount) do
    {:error, :not_enough_funds}
  end

  def is_valid?(username) do
    case get_user_from_username(username) do
      {:atomic, []} -> false
      _ -> true
    end
  end

  def from_username(username) do
    case get_user_from_username(username) do
      {:atomic, [user]} -> user
      _ -> {:error, :not_found}
    end
  end

  def list do
    {:atomic, users} = :mnesia.transaction(fn -> :mnesia.match_object({Users, :_, :_, :_, :_}) end)
    users |> Enum.map(&from_record/1)
  end

  def valid_password(username, password) do
    case get_user(username) do
      {:user, user} ->
        if checkpw(password, user.password_hash) do
          {:user, user}
        else
          :unauthorized
        end
      other -> other
    end
  end

  defp save(user) do
    case :mnesia.transaction(fn ->
      :mnesia.write({
        Users,
        user.id,
        user.username,
        user.password_hash,
        user.transactions})
    end) do
      {:atomic, :ok} -> :ok
      other -> {:error, other}
    end
  end

  defp get_user_from_username(username) do
    :mnesia.transaction(fn ->
      :mnesia.match_object({Users, :_, username, :_, :_})
    end)
  end

  defp get_user_from_id(id) do
    :mnesia.transaction(fn ->
      :mnesia.match_object({Users, id, :_, :_, :_})
    end)
  end

  defp from_record({Users, id, username, pass, transactions}) do
    investment = get_investment(transactions)
    return = get_return(transactions)
    %{
      id: id,
      username: username,
      password_hash: pass,
      transactions: transactions,
      balance: get_balance(transactions),
      investment: investment,
      return: return,
      roi: roi(investment, return)
    }
  end

  defp roi(investment, _return) when investment <= 0, do: 0.0
  defp roi(investment, return), do: (return - investment) / investment
end