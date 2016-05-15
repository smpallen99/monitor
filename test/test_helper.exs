ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Monitor.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Monitor.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Monitor.Repo)

