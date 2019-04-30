defmodule JobProcessingTest do
  use ExUnit.Case

  test "with one task requires other task" do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1"
        },
        %{
          "name" => "task-2"
        }
      ]
    }

    assert JobProcessing.get_ordered_commands(tasks) == ["task-1", "task-2"]
  end

  test "with tasks requiring other tasks" do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "touch /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "cat /tmp/file1",
          "requires" => [
            "task-3"
          ]
        },
        %{
          "name" => "task-3",
          "command" => "echo 'Hello World!' > /tmp/file1",
          "requires" => [
            "task-1"
          ]
        },
        %{
          "name" => "task-4",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2",
            "task-3"
          ]
        }
      ]
    }

    assert JobProcessing.get_ordered_commands(tasks) == ["task-1", "task-3", "task-2", "task-4"]
  end
end
