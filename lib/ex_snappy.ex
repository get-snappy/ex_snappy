defmodule ExSnappy do
  def snap(name, html, options \\ %{}) do
    # send HTML and options to go-snappy
    post(name, html, options)
  end

  def post(name, html, options) do
    # send HTML and options to go-snappy
    endpoint = Application.get_env(:ex_snappy, :endpoint)

    url = Path.join([endpoint, "snappy-api", "snapshot", UUID.uuid4()])

    req_options = Application.get_env(:ex_snappy, :req_options, [])

    body = %{
      "name" => name,
      "html" => html,
      "options" => options
    }

    options =
      [json: body]
      |> Keyword.merge(req_options)

    request = Req.post(url, options)

    case request do
      {:ok, %Req.Response{status: 200, body: "OK"}} ->
        :ok

      {:ok, %Req.Response{status: status}} ->
        {:error, "Error: #{status}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
