defmodule Entropy.BankController do
  use Entropy.Web, :controller
  alias Entropy.Bank

  def index(conn, _params) do
    bank_info = Bank.info() |> transform_accounts

    conn
    |> put_status(200)
    |> json(%{bank: bank_info})
  end

  defp transform_accounts(%{:accounts => accounts} = bank_info) do
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
end
