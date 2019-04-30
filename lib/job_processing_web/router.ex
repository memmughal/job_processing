defmodule JobProcessingWeb.Router do
  use JobProcessingWeb, :router

  pipeline :api do
    plug :accepts, ["json", "text"]
  end

  scope "/", JobProcessingWeb do
    pipe_through :api

    post "/process-jobs", JobProcessingController, :process_jobs
  end
end
