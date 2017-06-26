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

  defp public_info(user) do
    Map.drop(user, [:password_hash, :id, :transactions])
  end
end
