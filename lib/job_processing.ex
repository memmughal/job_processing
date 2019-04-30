defmodule JobProcessing do
  @moduledoc """
  this module performs the processing to fix order of the commands
  """
  @table :tasks

  def get_ordered_commands(%{"tasks" => tasks}) when is_list(tasks) do
    graph = initialize()

    graph =
      tasks
      |> Enum.reduce(graph, fn v, graph -> build_graph(graph, v) end)

    with {:ok, _graph} <- check_if_graph_is_cyclic(graph) do
      result =
        graph
        |> Graph.postorder()
        |> Enum.map(fn v -> get_metadata(v) end)

      {:ok, result}
    end
  end

  def get_ordered_commands(_tasks) do
    {:error, :unprocessable_entity}
  end

  defp initialize do
    :ets.new(@table, [:named_table, :public])
    Graph.new()
  end

  defp check_if_graph_is_cyclic(graph) do
    graph
    |> Graph.is_acyclic?()
    |> case do
      true -> {:ok, graph}
      false -> {:error, :cyclic_dependency_exist}
    end
  end

  defp get_metadata(vertex) do
    [{_vertex, data}] = :ets.lookup(@table, vertex)

    Map.take(data, ["name", "command"])
  end

  defp build_graph(graph, %{"name" => name} = data) do
    :ets.insert(@table, {name, data})
    add_vertices_edges(graph, data)
  end

  defp build_graph(_graph, _data) do
    {:error, :unprocessable_entity}
  end

  defp add_vertices_edges(graph, %{"name" => name, "requires" => []}) do
    Graph.add_vertex(graph, name)
  end

  defp add_vertices_edges(graph, %{"name" => name, "requires" => requires}) do
    edges = get_all_edges(name, requires)

    graph
    |> Graph.add_vertex(name)
    |> Graph.add_edges(edges)
  end

  defp add_vertices_edges(graph, %{"name" => name}) do
    Graph.add_vertex(graph, name)
  end

  defp get_all_edges(name, requires) do
    Enum.map(requires, &get_edge(name, &1))
  end

  defp get_edge(name, req) do
    {name, req}
  end
end
