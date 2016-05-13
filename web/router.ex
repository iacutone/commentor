defmodule Commentor.Router do
  use Commentor.Web, :router

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

  scope "/api", Commentor do
    pipe_through :api

    post "/trello", ApiController, :trello
    post "/pivotal", ApiController, :pivotal
  end

  scope "/", Commentor do
    pipe_through :browser # Use the default browser stack

    resources "/users", UserController

    get "/", UserController, :request
  end

  scope "/auth", Commentor do
    pipe_through :browser

    get "/:provider", UserController, :request
    get "/:provider/callback", UserController, :callback
  end
end
