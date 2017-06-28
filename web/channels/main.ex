defmodule Entropy.MainChannel do
  use Phoenix.Channel
  alias Entropy.User
  alias Entropy.Bank

  def join("main:init", _message, socket) do
    state = %{
      authenticated: false,
      bank: Bank.info() |> Bank.export()
    }
    {:ok, state, socket}
  end

  def join(_private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end