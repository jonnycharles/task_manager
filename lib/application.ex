defmodule TaskManager.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: TaskManager.TaskSupervisor},
      {TaskManager.WorkerSupervisor, []},
      {TaskManager.Dispatcher, []}
    ]

    opts = [strategy: :one_for_one, name: TaskManager.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
