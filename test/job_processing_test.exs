defmodule JobProcessingTest do
  use ExUnit.Case

  test "with no task requires other task" do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "rm /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "echo 'Hello World!'"
        }
      ]
    }

    assert JobProcessing.get_ordered_commands(tasks) ==
             {:ok,
              [
                %{
                  "name" => "task-1",
                  "command" => "rm /tmp/file1"
                },
                %{
                  "name" => "task-2",
                  "command" => "echo 'Hello World!'"
                }
              ]}
  end

  test "with task requires create cyclic dependency" do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "rm /tmp/file1",
          "requires" => [
            "task-2"
          ]
        },
        %{
          "name" => "task-2",
          "command" => "echo 'Hello World!'",
          "requires" => [
            "task-1"
          ]
        }
      ]
    }

    assert JobProcessing.get_ordered_commands(tasks) == {:error, :cyclic_dependency_exist}
  end

  test "with one task requires other task" do
    tasks = %{
      "tasks" => [
        %{
          "name" => "task-1",
          "command" => "rm /tmp/file1"
        },
        %{
          "name" => "task-2",
          "command" => "echo 'Hello World!'",
          "requires" => [
            "task-1"
          ]
        }
      ]
    }

    assert JobProcessing.get_ordered_commands(tasks) ==
             {:ok,
              [
                %{
                  "name" => "task-1",
                  "command" => "rm /tmp/file1"
                },
                %{
                  "name" => "task-2",
                  "command" => "echo 'Hello World!'"
                }
              ]}
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

    assert JobProcessing.get_ordered_commands(tasks) ==
             {:ok,
              [
                %{
                  "name" => "task-1",
                  "command" => "touch /tmp/file1"
                },
                %{
                  "name" => "task-3",
                  "command" => "echo 'Hello World!' > /tmp/file1"
                },
                %{
                  "name" => "task-2",
                  "command" => "cat /tmp/file1"
                },
                %{
                  "name" => "task-4",
                  "command" => "rm /tmp/file1"
                }
              ]}
  end
end
