defmodule ExSnappy do
  @moduledoc """
  ExSnappy is a library for taking snapshots of HTML using the Go Snappy service.
  """

  @doc """
  Takes a snapshot of the given HTML and sends it to the Go Snappy service.

  Uses the name of the test function as the snapshot name.
  """
  defmacro snap(html) do
    if Application.get_env(:ex_snappy, :enabled) do
      test_name = ExSnappy.Utils.generate_test_name(__CALLER__)

      quote do
        ExSnappy.API.process_snapshot(unquote(test_name), unquote(html), %{})
      end
    end
  end

  @doc """
  Takes a snapshot of the given HTML with the specified name 

  Uses the name of the test function as the snapshot name plus a suffix. Use if you need to run
  multiple snapshots in the same test function.
  """
  defmacro snap(name, html) do
    if Application.get_env(:ex_snappy, :enabled) do
      test_name = ExSnappy.Utils.generate_test_name(__CALLER__, name)

      quote do
        ExSnappy.API.process_snapshot(unquote(test_name), unquote(html), %{})
      end
    end
  end

  @doc """
  Takes a snapshot of the given HTML with the specified name and options.

  Uses the name of the test function as the snapshot name plus a suffix. Use if you need to run
  multiple snapshots in the same test function.

  Options are passed to the Go Snappy service to control the rendered screenshots.
  """
  defmacro snap(name, html, options) do
    if Application.get_env(:ex_snappy, :enabled) do
      test_name = ExSnappy.Utils.generate_test_name(__CALLER__, name)

      quote do
        ExSnappy.API.process_snapshot(
          unquote(test_name),
          unquote(html),
          unquote(options)
        )
      end
    end
  end
end
