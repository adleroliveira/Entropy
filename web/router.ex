defmodule Entropy.Router do
  use Entropy.Web, :router

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Entropy do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Entropy do
    pipe_through :api
    get "/bank", BankController, :index
    get "/accounts/:username", AccountController, :accounts
    get "/accounts", AccountController, :accounts
    get "/users", UserController, :index
    get "/ranking", UserController, :ranking
    get "/users/:username", UserController, :show
    get "/logout", UserController, :logout
    post "/login", UserController, :login
    post "/users/register", UserController, :register
  end
end
