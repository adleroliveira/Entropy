defmodule Entropy.BankController do
  use Entropy.Web, :controller
  alias Entropy.Bank

  def index(conn, _params) do
    bank_info = Bank.info() |> Bank.export()

    conn
    |> put_status(200)
    |> json(%{bank: bank_info})
  end
end
