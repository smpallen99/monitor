use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :monitor, Monitor.Endpoint,
  secret_key_base: "2XpgAjMCraXNbmc8nprUz9fWyUdoM7klMxMVgNXzb7h9aOkbrg96JaLJrLdnBoYb"

# Configure your database
config :monitor, Monitor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "monitor_prod",
  pool_size: 20
