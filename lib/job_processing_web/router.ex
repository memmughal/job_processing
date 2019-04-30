defmodule JobProcessingWeb.Router do
  use JobProcessingWeb, :router

  alias JobProcessingWeb.Plugs.ValidateTasksRequestBody

  pipeline :api do
    plug :accepts, ["json", "text"]
    plug ValidateTasksRequestBody
  end

  scope "/", JobProcessingWeb do
    pipe_through :api

    post "/process-jobs", JobProcessingController, :process_jobs
  end
end
