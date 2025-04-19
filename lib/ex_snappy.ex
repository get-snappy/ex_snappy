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

  You can also pass `:playwright_options` to set options for Playwright.  Currently only `:full_page` is supported, which will default to `true`.

  You can globally set whether to enable full page screenshots by setting the `:full_page` option in your config file to `false`.

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
    end
  end
end
