defmodule Service.Router do
  use Service.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Service do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/ping", PageController, :ping
  end

  # Other scopes may use custom stacks.
  # scope "/api", Service do
  #   pipe_through :api
  # end
end
