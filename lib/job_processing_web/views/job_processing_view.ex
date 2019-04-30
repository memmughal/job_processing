defmodule JobProcessingWeb.JobProcessingView do
  use JobProcessingWeb, :view

  def render("jobs.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, __MODULE__, "task.json", as: :task)}
  end

  def render("task.json", %{task: task}) do
    Map.take(task, ["name", "command"])
  end
end
