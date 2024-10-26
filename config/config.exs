# config/config.exs
import Config

# Import environment specific config
import_config "#{config_env()}.exs"
