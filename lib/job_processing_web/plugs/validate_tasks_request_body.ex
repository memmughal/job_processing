defmodule JobProcessingWeb.Plugs.ValidateTasksRequestBody do
  @moduledoc "Plug for validating request body against schema"

  import Plug.Conn

  alias ExJsonSchema.{Schema, Validator}

  def init(default), do: default

  def call(%Plug.Conn{body_params: body_params} = conn, _opts) do
    {:ok, file_content} = get_json_schema()
    {:ok, json_schema} = Jason.decode(file_content)
    schema = %Schema.Root{} = Schema.resolve(json_schema)

    case Validator.validate(schema, body_params) do
      :ok -> conn
      _errors -> send_error_response(conn)
    end
  end

  def call(_conn, _opts), do: raise("no body params found")

  defp get_json_schema do
    path_to_priv_dir = Application.app_dir(:job_processing, "priv")
    file_path = Path.join(path_to_priv_dir, "schemas/tasks_request.json")

    File.read(file_path)
  end

  defp send_error_response(conn) do
    conn
    |> send_resp(400, "Bad Request")
    |> halt()
  end
end
