defmodule TaskManager.ApplicationTest do
  use ExUnit.Case

  test "supervision tree starts correctly" do
    # Verify all supervisors and processes are running
    assert Process.whereis(TaskManager.Supervisor) != nil
    assert Process.whereis(TaskManager.TaskSupervisor) != nil
    assert Process.whereis(TaskManager.WorkerSupervisor) != nil
    assert Process.whereis(TaskManager.Dispatcher) != nil

    # Verify all workers are running
    for id <- 1..5 do
      assert Registry.lookup(TaskManager.WorkerRegistry, id) != []
    end
  end
end
