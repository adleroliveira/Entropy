defmodule Entropy.User do
  import Comeonin.Bcrypt

  defstruct [
    :id,
    :username,
    :password_hash,
    balance: 10.00
  ]

  def new(username, password) do
    %__MODULE__{
      id: UUID.uuid4(),
      username: username,
      password_hash: hashpwsalt(password)
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
      attributes: [:id, :username, :password_hash, :balance],
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

  def add_funds(id_or_username, amount) do
    case get_user(id_or_username) do
      {:user, user} -> user |> Map.put(:balance, user.balance + amount) |> save()
      other -> other
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

  def deduct(id, amount) do
    case get_user_from_id(id) do
      {:atomic, [user_record]} ->
        user = from_record(user_record)
        deduct_if_available(user, user.balance, amount)
      _ -> {:error, :not_found}
    end
  end

  def deduct_if_available(user, balance, amount) when balance >= amount do
    user
    |> Map.put(:balance, balance - amount)
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

  defp save(user) do
    case :mnesia.transaction(fn ->
      :mnesia.write({
        Users,
        user.id,
        user.username,
        user.password_hash,
        user.balance})
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

  def list do
    {:atomic, users} = :mnesia.transaction(fn -> :mnesia.match_object({Users, :_, :_, :_, :_}) end)
    users |> Enum.map(&from_record/1)
  end

  defp from_record({Users, id, username, pass, balance}) do
    %__MODULE__{
      id: id,
      username: username,
      password_hash: pass,
      balance: balance
    }
  end
end