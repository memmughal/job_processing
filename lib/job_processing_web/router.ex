defmodule JobProcessingWeb.Router do
  use JobProcessingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JobProcessingWeb do
    pipe_through :api
  end
end
