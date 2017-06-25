# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :entropy, Entropy.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aLGKjsSNsZnc2vxOx8SleFbAKO2Rv9H3sh0J1pdwSfFU/RjNx8gTZLqyiBjrROJM",
  render_errors: [view: Entropy.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Entropy.PubSub,
           adapter: Phoenix.PubSub.PG2]


config :haikunator, :adjectives, ~w(
  autumn hidden bitter misty silent empty dry dark summer
  icy delicate quiet white cool spring winter patient
  twilight dawn crimson wispy weathered blue billowing
  broken cold damp falling frosty green long late lingering
  bold little morning muddy old red rough still small
  sparkling throbbing shy wandering withered wild black
  young holy solitary fragrant aged snowy proud floral
  restless divine polished ancient purple lively nameless
)

config :haikunator, :nouns, ~w(
   waterfall river breeze moon rain wind sea morning
   snow lake sunset pine shadow leaf dawn glitter forest
   hill cloud meadow sun glade bird brook butterfly
   bush dew dust field fire flower firefly feather grass
   haze mountain night pond darkness snowflake silence
   sound sky shape surf thunder violet water wildflower
   wave water resonance sun wood dream cherry tree fog
   frost voice paper frog smoke star
)
# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
