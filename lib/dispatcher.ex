defmodule TaskManager.Dispatcher do
  use GenServer
  require Logger

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server callbacks
  def init(_) do
    {:ok, %{task_queue: :queue.new(), task_refs: %{}}}
  end

  # Modified to properly return the task reference
  def handle_call({:submit_task, task}, from, state) do
    worker_id = select_worker()

    # Start the task and get its reference
    task_pid = Task.Supervisor.async_nolink(TaskManager.TaskSupervisor, fn ->
      TaskManager.Worker.process_task(worker_id, task)
    end)

    # Store the caller information with the task reference
    new_state = %{state |
      task_refs: Map.put(state.task_refs, task_pid.ref, from)
    }

    # Return the task reference to the caller
    {:reply, task_pid.ref, new_state}
  end

  # Handle successful task completion
  def handle_info({ref, {:ok, task_id}}, state) do
    # Clean up the DOWN message
    Process.demonitor(ref, [:flush])

    # Find and notify the original caller
    if from = Map.get(state.task_refs, ref) do
      send(elem(from, 0), {:task_completed, ref})
    end

    Logger.info("Task #{task_id} completed successfully with reference #{inspect(ref)}")
    {:noreply, %{state | task_refs: Map.delete(state.task_refs, ref)}}
  end

  # Handle task failures
  def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
    Logger.info("Received DOWN message for reference #{inspect(ref)}")

    # Find and notify the original caller
    if from = Map.get(state.task_refs, ref) do
      send(elem(from, 0), {:task_failed, ref, reason})
    end

    {:noreply, %{state | task_refs: Map.delete(state.task_refs, ref)}}
  end

  # Catch-all clause for unexpected messages
  def handle_info(msg, state) do
    Logger.warning("Received unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  # Load balancing logic
  defp select_worker do
    1..5
    |> Enum.map(fn id -> {id, TaskManager.Worker.get_load(id)} end)
    |> Enum.min_by(fn {_id, load} -> load end)
    |> elem(0)
  end
end
