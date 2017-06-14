defmodule Entropy.User do
  import Comeonin.Bcrypt

  defstruct [
    :id,
    :username,
    :password_hash,
    status: :active
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
      attributes: [:id, :username, :password_hash, :status],
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
        user.status})
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
end