# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Monitor.Repo.insert!(%Monitor.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Monitor.{Repo, User, Server, Service}

Faker.start

Repo.delete_all Service
Repo.delete_all Server
Repo.delete_all User

users =
for _ <- 0..10 do
  Repo.insert! %User{name: Faker.Name.name, email: Faker.Internet.email}
end

servers =
for _ <- 0..15 do
  u = Enum.random users
  status = Enum.random Server.status_options
  Repo.insert! %Server{name: Faker.Commerce.product_name_adjective,
    email: Faker.Internet.email, user_id: u.id, status: status}
end

[
  %Service{
    name: Faker.Commerce.product_name_adjective, status: "offline",
    server_id: Enum.at(servers, 0).id, request_url: "http://localhost:4005/ping",
    expected_response: ~s({"response": "pong"})
  },
  %Service{
    name: Faker.Commerce.product_name_adjective, status: "offline",
    server_id: Enum.at(servers, 1).id, request_url: "http://localhost:4006/ping",
    expected_response: ~s({"response": "pong"})
  },
]
|> Enum.each(&(Repo.insert! &1))

