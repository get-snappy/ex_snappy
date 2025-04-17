defmodule ExSnappy do
  @moduledoc """
  ExSnappy is a library for taking snapshots of HTML using the Go Snappy service.
  """

  @doc """
  Takes a snapshot of the given HTML and sends it to the Go Snappy service.

  Uses the name of the test function as the snapshot name.
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
