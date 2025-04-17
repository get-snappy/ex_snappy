defmodule ExSnappy.Utils do
  @moduledoc false

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

  def generate_test_name(caller, nil) do
    case caller do
      {test_name, _arity} ->
        test_name
        |> to_string()
        |> String.trim_leading("test ")

      _ ->
        raise("TestSnapshot.snapshot/1 must be called from a test function")
    end
  end

  def generate_test_name(caller, name) do
    case caller do
      {test_name, _arity} ->
        trimmed_name = test_name |> to_string() |> String.trim_leading("test ")
        "#{trimmed_name} - #{name}"

      _ ->
        raise("TestSnapshot.snapshot/1 must be called from a test function")
    end
  end
end
