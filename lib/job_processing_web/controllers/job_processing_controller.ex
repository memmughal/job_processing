defmodule JobProcessingWeb.JobProcessingController do
  use JobProcessingWeb, :controller

  def process_jobs(conn, %{} = params) do
    with {:ok, result} <- JobProcessing.get_ordered_commands(params) do
      conn
      |> get_req_header("accept")
      |> send_response(result, conn)
    else
      {:error, :cyclic_dependency_exist} -> send_resp(conn, 400, "Cyclic dependency exists")
      {:error, :unprocessable_entity} -> send_resp(conn, 422, "Unprocessable entity")
      error -> error
    end
  end

  def process_jobs(conn, _params) do
    send_resp(conn, 422, "unprocessable entity")
  end

  defp send_response(["text/plain"], response, conn) do
    commands = format_text(response)
    send_resp(conn, 200, commands)
  end

  defp send_response(_content_type, response, conn) do
    render(conn, "jobs.json", %{tasks: response})
  end

  defp format_text(response) when length(response) > 0 do
    commands =
      response
      |> Enum.map(fn job -> job["command"] end)
      |> Enum.join("\n")

    "#!/usr/bin/env bash" <> "\n" <> commands
  end

  defp format_text(response) do
    response
  end
end
