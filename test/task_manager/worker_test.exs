defmodule TaskManager.WorkerTest do
  use ExUnit.Case

  setup do
    task = %TaskManager.Task{
      id: "test_task_1",
      complexity: 1,
      data: "test data"
    }
    {:ok, task: task}
  end

  test "worker processes task correctly", %{task: task} do
    worker_id = 1

    # Process task and verify response
    assert {:ok, "test_task_1"} = TaskManager.Worker.process_task(worker_id, task)

    # Verify load increased
    assert TaskManager.Worker.get_load(worker_id) > 0
  end

  test "worker handles multiple tasks", %{task: task} do
    worker_id = 2
    initial_load = TaskManager.Worker.get_load(worker_id)

    # Process multiple tasks
    results = for i <- 1..3 do
      modified_task = %{task | id: "test_task_#{i}"}
      TaskManager.Worker.process_task(worker_id, modified_task)
    end

    # Verify all tasks completed successfully
    assert Enum.all?(results, fn result ->
      match?({:ok, _}, result)
    end)

    # Verify load increased
    assert TaskManager.Worker.get_load(worker_id) > initial_load
  end
end
