defmodule ExSnappy.UtilsTest do
  use ExUnit.Case, async: false

  setup do
    on_exit(fn ->
      Application.put_env(:ex_snappy, :test_prefix, nil)
    end)
  end

  test "Strings script tags" do
    assert ExSnappy.Utils.strip_script_tags("""
             <html>
               <script></script>
               <script src="/app.js"></script>
               <script type="module" src="/app-modern.esm"></script>
             </html> 
           """) == "<html></html>"
  end

  test "Wraps with html if missing <head>" do
    Application.put_env(:ex_snappy, :wrapper_fn, fn inner_content ->
      """
      <!DOCTYPE html>
      <html lang="en" class="[scrollbar-gutter:stable]">
      <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <link phx-track-static rel="stylesheet" href="/assets/app.css" />
      </head>
      <body class="bg-white antialiased dark:bg-gray-900 dark:text-gray-100">
      #{inner_content}
      </body>
      </html>
      """
    end)

    assert ExSnappy.Utils.maybe_wrap_html("<div></div>") ==
             """
             <!DOCTYPE html>
             <html lang="en" class="[scrollbar-gutter:stable]">
             <head>
             <meta charset="utf-8" />
             <meta name="viewport" content="width=device-width, initial-scale=1" />
             <link phx-track-static rel="stylesheet" href="/assets/app.css" />
             </head>
             <body class="bg-white antialiased dark:bg-gray-900 dark:text-gray-100">
             <div></div>
             </body>
             </html>
             """
  end

  test "generates test name without explicit name" do
    caller = {ExSnappyTest, 1}
    assert ExSnappy.Utils.generate_test_name(caller, nil) == "Elixir.ExSnappyTest"
  end

  test "adds a prefix to the test name" do
    Application.put_env(:ex_snappy, :test_prefix, "Ubuntu 20.04")
    caller = {ExSnappyTest, 1}

    assert ExSnappy.Utils.generate_test_name(caller, "my-snapshot") ==
             "(Ubuntu 20.04) Elixir.ExSnappyTest - my-snapshot"
  end
end
