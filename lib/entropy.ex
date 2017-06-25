defmodule Entropy do
  use Application
  alias Entropy.User

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    :mnesia.create_schema([node()])
    :mnesia.start()
    User.create_table()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Entropy.Endpoint, []),
      supervisor(Entropy.Manager, []),
      supervisor(Entropy.Skynet, []),
      worker(Entropy.Bank, [])
      # Start your own worker by calling: Entropy.Worker.start_link(arg1, arg2, arg3)
      # worker(Entropy.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Entropy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Entropy.Endpoint.config_change(changed, removed)
    :ok
  end
end
