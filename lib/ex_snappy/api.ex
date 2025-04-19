defmodule ExSnappy.API do
  @moduledoc false
  def process_snapshot(name, html, options) do
    # send HTML and options to go-snappy
    wrapped = ExSnappy.Utils.maybe_wrap_html(html)

    html =
      case Keyword.get(options, :strip_script_tags, true) do
        true -> ExSnappy.Utils.strip_script_tags(wrapped)
        _ -> wrapped
      end

    post(name, html, options)
  end

  def post(name, html, options) do
    # send HTML and options to go-snappy
    endpoint = Application.get_env(:ex_snappy, :endpoint, "http://localhost:4050")
    full_page = Application.get_env(:ex_snappy, :full_page, true)

    url = Path.join([endpoint, "snappy-api", "snapshot", UUID.uuid4()])

    req_options = Application.get_env(:ex_snappy, :req_options, [])

    playwright_options =
      Keyword.get(options, :playwright_options, %{full_page: full_page})
      |> Enum.into(%{})

    options =
      Keyword.drop(options, [:name, :strip_script_tags, :playwright_options])
      |> Enum.into(%{})

    body = %{
      "name" => name,
      "html" => html,
      "options" => options,
      "playwright_options" => playwright_options
    }

    dbg(body["playwright_options"])

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
