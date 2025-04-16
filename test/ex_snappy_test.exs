defmodule ExSnappyTest do
  use ExUnit.Case
  doctest ExSnappy

  test "Simple success" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("test-name", "<html></html>") == :ok
  end

  test "Strings script tags" do
    assert ExSnappy.strip_script_tags("""
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
      <meta name="csrf-token" content={get_csrf_token()} />
      <link phx-track-static rel="stylesheet" href="/assets/app.css" />
      </head>
      <body class="bg-white antialiased dark:bg-gray-900 dark:text-gray-100">
      #{inner_content}
      </body>
      </html>
      """
    end)

    assert ExSnappy.maybe_wrap_html("<div></div>") ==
             """
             <!DOCTYPE html>
             <html lang="en" class="[scrollbar-gutter:stable]">
             <head>
             <meta charset="utf-8" />
             <meta name="viewport" content="width=device-width, initial-scale=1" />
             <meta name="csrf-token" content={get_csrf_token()} />
             <link phx-track-static rel="stylesheet" href="/assets/app.css" />
             </head>
             <body class="bg-white antialiased dark:bg-gray-900 dark:text-gray-100">
             <div></div>
             </body>
             </html>
             """
  end

  test "Passing along options" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("test-name", "<html></html>", %{dimensions: []}) == :ok
  end

  test "Go Snappy not running" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.transport_error(conn, :econnrefused)
    end)

    assert ExSnappy.snap("test-name", "<html></html>") ==
             {:error,
              %Req.TransportError{
                reason: :econnrefused
              }}
  end
end
