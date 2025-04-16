import Config

config :ex_snappy,
  enabled: false,
  endpoint: "http://localhost:4050",
  req_options: []

import_config("#{config_env()}.exs")
