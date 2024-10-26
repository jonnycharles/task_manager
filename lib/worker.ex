# lib/task_manager/worker.ex
defmodule TaskManager.Worker do
  use GenServer
  require Logger

  # Client API
  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  def process_task(worker_id, task) do
    GenServer.call(via_tuple(worker_id), {:process_task, task})
  end

  def get_load(worker_id) do
    GenServer.call(via_tuple(worker_id), :get_load)
  end

  # Server callbacks
  def init(id) do
    {:ok, %{id: id, tasks_processed: 0, current_load: 0}}
  end

  def handle_call({:process_task, task}, _from, state) do
    # Stimulate processing time based on task complexity
    processing_time = task.complexity * 1000
    Process.sleep(processing_time)

    new_state = %{state |
      tasks_processed: state.tasks_processed + 1,
      current_load: state.current_load + task.complexity
    }

    Logger.info("Worker #{state.id} processed task #{task.id}")

    {:reply, {:ok, task.id}, new_state}
  end

  def handle_call(:get_load, _from, state) do
    {:reply, state.current_load, state}
  end

  defp via_tuple(id) do
    {:via, Registry, {TaskManager.WorkerRegistry, id}}
  end
end
