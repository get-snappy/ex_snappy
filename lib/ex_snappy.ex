defmodule ExSnappy do
  @moduledoc """
  ExSnappy is a library for taking snapshots of HTML using the Go Snappy service.
  """

  @doc """
  Takes a snapshot of the given HTML and sends it to the Go Snappy service.

  Uses the name of the test function as the snapshot name.

  You can explicitly set the name of the snapshot by passing the `:name` option.

  By default, any <script> tags in the HTML will be removed before sending to the Go Snappy service.
  This is to ensure that the DOM will not be modified when processed for screenshots.

  Other options will be passed to the Go Snappy service, such as setting dimensions.

  You can also pass `:playwright_options` to set options for Playwright.  



  # Playwright Options

  `:full_page`, which defaults to `true`.
  You can globally set whether to enable full page screenshots by setting the `:full_page` option in your config file to `false`.

  `:dark_mode`, which defaults to `false`.

  `:locator`, which can be a CSS selector which should target a *single* element.  This will limit 
  the screenshot size to the bounding box of the element.  This is useful for testing specific elements and components.

  # Option

  `:dimensions`, which can be a list of maps with `:width` and `:height` keys.  
  Where dimensions aren't specified, the default will be 1920x1080


  ## Example

  ```elixir
  snap(html, name: "my_snapshot", 
    playwright_options: %{
      dark_mode: true,
      locator: ".my-element"
    },
    dimensions: [
      %{width: 1280, height: 720},
      %{width: 1920, height: 1080}
    ]
  )
  ```

  """
  defmacro snap(html, options \\ []) do
    if Application.get_env(:ex_snappy, :enabled) do
      function_name = __CALLER__.function

      quote bind_quoted: [function_name: function_name, options: options, html: html] do
        test_name =
          case Keyword.get(options, :name) do
            nil -> ExSnappy.Utils.generate_test_name(function_name, nil)
            name -> ExSnappy.Utils.generate_test_name(function_name, name)
          end

        ExSnappy.API.process_snapshot(test_name, html, options)
      end
    else
      html
    end
  end
end
