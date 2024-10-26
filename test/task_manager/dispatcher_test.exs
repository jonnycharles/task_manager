# test/task_manager/dispatcher_test.exs
defmodule TaskManager.DispatcherTest do
  use ExUnit.Case
  require Logger

  setup do
    # Create a test task
    task = %TaskManager.Task{
      id: "test_task_1",
      complexity: 1,
      data: "test data"
    }
    {:ok, task: task}
  end

  test "dispatcher submits task to worker", %{task: task} do
    # Start a task and get its reference
    task_ref = GenServer.call(TaskManager.Dispatcher, {:submit_task, task})

    # Assert we receive the completion message
    assert_receive {:task_completed, ^task_ref}, 10000
  end

  test "load balancing distributes tasks evenly" do
    tasks = for i <- 1..10 do
      %TaskManager.Task{
        id: "test_task_#{i}",
        complexity: 1,
        data: "test data"
      }
    end

    # Submit tasks
    Enum.each(tasks, fn task ->
      GenServer.call(TaskManager.Dispatcher, {:submit_task, task})
      Process.sleep(100) # Give some time for task distribution
    end)

    # Check load distribution
    loads = for id <- 1..5 do
      TaskManager.Worker.get_load(id)
    end

    # Verify that no worker has significantly more load than others
    max_load = Enum.max(loads)
    min_load = Enum.min(loads)
    assert max_load - min_load <= 2
  end
end
