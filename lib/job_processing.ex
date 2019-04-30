defmodule JobProcessing do
  @moduledoc """
  this module performs the processing to fix order of the commands
  """
  @table :tasks

  def get_ordered_commands(%{"tasks" => tasks}) when is_list(tasks) do
    :ets.new(@table, [:named_table, :public])
    g = Graph.new()

    try do
      g =
        tasks
        |> Enum.reduce(g, fn v, g -> build_graph(g, v) end)

      g
      |> Graph.is_acyclic?()
      |> case do
        true -> g
        false -> raise(ArgumentError, "Cycles exist")
      end
      |> Graph.postorder()
      |> Enum.map(fn v -> get_metadata(v) end)
    rescue
      _error -> :error
    end
  end

  def get_ordered_commands(_tasks) do
    :error
  end

  defp get_metadata(vertex) do
    [{_vertex, data}] = :ets.lookup(@table, vertex)

    Map.take(data, ["name", "command"])
  end

  defp build_graph(g, %{"name" => name} = data) do
    :ets.insert(@table, {name, data})
    add_vertices_edges(g, data)
  end

  defp build_graph(_g, _data) do
    raise(ArgumentError, "Invalid request format")
  end

  defp add_vertices_edges(g, %{"name" => name, "requires" => []}) do
    Graph.add_vertex(g, name)
  end

  defp add_vertices_edges(g, %{"name" => name, "requires" => requires}) do
    edges = get_all_edges(name, requires)

    g
    |> Graph.add_vertex(name)
    |> Graph.add_edges(edges)
  end

  defp add_vertices_edges(g, %{"name" => name}) do
    Graph.add_vertex(g, name)
  end

  defp get_all_edges(name, requires) do
    Enum.map(requires, &get_edge(name, &1))
  end

  defp get_edge(name, req) do
    {name, req}
  end
end
