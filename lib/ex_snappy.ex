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
  """
  defmacro snap(html, options \\ []) do
    if Application.get_env(:ex_snappy, :enabled) do
      function_name = __CALLER__.function

      quote do
        test_name =
          case Keyword.get(unquote(options), :name) do
            nil -> ExSnappy.Utils.generate_test_name(unquote(function_name), nil)
            name -> ExSnappy.Utils.generate_test_name(unquote(function_name), name)
          end

        ExSnappy.API.process_snapshot(test_name, unquote(html), unquote(options))
      end
    end
  end
end
