import Config

config :ex_snappy,
  enabled: System.get_env("EX_SNAPPY_ENABLED") == "true",
  req_options: [
    plug: {Req.Test, ExSnappy}
  ]
