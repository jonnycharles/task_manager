defmodule TaskManager.TestHelpers do
  def wait_for_tasks(count, timeout \\ 5000) do
    start_time = System.monotonic_time(:millisecond)
    do_wait_for_tasks(count, start_time, timeout)
  end

  defp do_wait_for_tasks(0, _, _), do: :ok
  defp do_wait_for_tasks(count, start_time, timeout) do
    current_time = System.monotonic_time(:millisecond)
    if current_time - start_time > timeout do
      raise "Timeout waiting for tasks to complete"
    end

    Process.sleep(100)
    # Add implementation to check completed tasks
    do_wait_for_tasks(count - 1, start_time, timeout)
  end
end
