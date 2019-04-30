defmodule JobProcessingWeb.JobProcessingController do
  use JobProcessingWeb, :controller

  def process_jobs(conn, %{} = params) do
    with :error <- JobProcessing.get_ordered_commands(params) do
      send_resp(conn, 400, "Bad Request")
    else
      response ->
        render(conn, "jobs.json", %{tasks: response})
    end
  end

  def process_jobs(conn, _params) do
    send_resp(conn, 422, "unprocessable entity")
  end
end
