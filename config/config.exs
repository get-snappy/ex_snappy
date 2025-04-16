import Config

config :ex_snappy,
  endpoint: "http://localhost:4050",
  req_options: []

import_config("#{config_env()}.exs")
