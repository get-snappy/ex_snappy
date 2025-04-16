import Config

config :ex_snappy,
  req_options: [
    plug: {Req.Test, ExSnappy}
  ]
