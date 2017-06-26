defmodule Entropy.ControllerUtils do
  use Entropy.Web, :controller
  
  def missing_parameters(conn) do
    conn
    |> put_status(422)
    |> json(%{ error: "Missing parameters" })
  end

  def response_error(conn, error) do
    conn
    |> put_status(500)
    |> json(%{ error: error })
  end
end