# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :monitor_server,
  monitor_url: "http://localhost:4000/servers/##MONITOR_ID##/active"


#     import_config "#{Mix.env}.exs"
