defmodule ExSnappy do
  def snap(name, html, options \\ %{}) do
    # send HTML and options to go-snappy
    wrapped = maybe_wrap_html(html)

    html =
      case Map.get(options, :strip_script_tags) do
        true -> strip_script_tags(wrapped)
        _ -> wrapped
      end

    post(name, html, options)
  end

  def post(name, html, options) do
    # send HTML and options to go-snappy
    endpoint = Application.get_env(:ex_snappy, :endpoint, "http://localhost:4050")

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

  def strip_script_tags(html) do
    # Remove script tags from the HTML
    cleansed =
      Floki.parse_document!(html)
      |> Floki.traverse_and_update(fn
        {"script", _, _} -> nil
        el -> el
      end)

    # Convert the modified HTML back to a string
    Floki.raw_html(cleansed)
  end

  def maybe_wrap_html(html) do
    # check if html has a head tag
    Floki.parse_document!(html)
    |> Floki.find("head")
    |> case do
      [] ->
        # if not, wrap it in a head and body tag
        wrapper_fn = Application.get_env(:ex_snappy, :wrapper_fn)

        if is_function(wrapper_fn) do
          # if wrapper_fn is a function, call it with the html
          wrapper_fn.(html)
        else
          # if not, return the html as is
          html
        end

      _ ->
        # if it does, return the html as is
        html
    end
  end
end
