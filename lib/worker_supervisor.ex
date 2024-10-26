defmodule TaskManager.WorkerSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = Enum.map(1..5, fn id ->
      %{
        id: {:worker, id},
        start: {TaskManager.Worker, :start_link, [id]},
        type: :worker,
        restart: :permanent
      }
    end)

    Registry.start_link(keys: :unique, name: TaskManager.WorkerRegistry)
    Supervisor.init(children, strategy: :one_for_one)
  end
end
