defmodule Entropy.UserController do
  use Entropy.Web, :controller
  alias Entropy.User
  alias Entropy.ControllerUtils

  def index(conn, _params) do
    users = User.list()
    |> Enum.map(&public_info/1)

    conn
    |> put_status(200)
    |> json(%{users: users})
  end

  def register(conn, %{"username" => username, "password" => password}) do
    create_user(conn, User.get_user(username), {username, password})
  end

  def register(conn, _params), do: ControllerUtils.missing_parameters(conn)

  def login(conn, %{"username" => username, "password" => password}) do
    case User.valid_password(username, password) do
      :unauthorized -> conn |> put_status(401) |> json(%{error: "unauthorized"})
      {:user, user} ->
        conn
        |> fetch_session()
        |> put_session(:current_user, user.id)
        |> put_status(200) |> json(%{user: user |> Map.drop([:password_hash])})
      _ -> ControllerUtils.response_error(conn, "Unable to authenticate user")
    end
  end

  def login(conn, _params), do: ControllerUtils.missing_parameters(conn)

  def logout(conn, _params) do
    conn
    |> fetch_session()
    |> delete_session(:current_user)
    |> put_status(200)
    |> json(%{logout: "ok"})
  end

  def ranking(conn, _params) do
    users = User.list()
    |> Enum.map(&public_info/1)
    |> Enum.sort(&(&1.roi > &2.roi))

    conn
    |> put_status(200)
    |> json(%{users: users})
  end

  def show(conn, %{"username" => username}) do
    case User.get_user(username) do
      {:user, user} -> conn |> put_status(200) |> json(public_info(user))
      other -> ControllerUtils.response_error(conn, other)
    end
  end

  def show(conn, _params), do: ControllerUtils.missing_parameters(conn)

  def current_user(conn) do
    conn
    |> fetch_session()
    |> get_session(:current_user)
  end

  def logged_in?(conn), do: !!current_user(conn)

  defp create_user(conn, {:error, :not_found}, {username, password}) do
    case User.create(username, password) do
      :ok -> show(conn, %{"username" => username})
      _   -> ControllerUtils.response_error(conn, "Unable to create user")
    end
  end

  defp create_user(conn, {:user, _user}, _) do
    conn.put_status(409) |> json(%{error: "Username already exists"})
  end

  defp public_info(user) do
    Map.drop(user, [:password_hash, :id, :transactions])
  end
end
