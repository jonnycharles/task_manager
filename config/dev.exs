# config/dev.exs
import Config

config :task_manager,
  worker_count: 5,
  task_supervisor_name: TaskManager.TaskSupervisor,
  worker_registry_name: TaskManager.WorkerRegistry,
  dispatcher_name: TaskManager.Dispatcher
