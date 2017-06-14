defmodule Entropy.PageController do
  use Entropy.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
