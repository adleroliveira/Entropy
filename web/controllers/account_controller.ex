defmodule Entropy.AccountController do
  use Entropy.Web, :controller
  alias Entropy.Bank
  alias Entropy.ControllerUtils, as: Utils

  def accounts(conn, %{"username" => username}) do
    case Bank.accounts_of(username) do
      {:error, :user_not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Invalid User"})
      accounts when is_list(accounts) ->
        conn
        |> put_status(200)
        |> json(%{accounts: accounts |> Enum.map(&transform_account/1)})
      _ -> Utils.response_error(conn, "Something went wrong when trying to fetch this users accounts")
    end
  end

  def accounts(conn, _params), do: Utils.missing_parameters(conn)

  defp transform_account(account) do
    account |> Map.update!(:balance, &:queue.to_list/1)
  end
end
