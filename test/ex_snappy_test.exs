defmodule ExSnappyTest do
  use ExUnit.Case
  doctest ExSnappy

  test "Without name" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("<html></html>") == :ok
  end

  test "With explicit name" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("<html></html>", name: "test") == :ok
  end

  test "Passing along options" do
    Req.Test.stub(ExSnappy, fn conn ->
      {:ok, body, _conn} = Plug.Conn.read_body(conn)
      decoded = Jason.decode!(body)

      assert decoded["options"]["dimensions"] == [%{"height" => 720, "width" => 1280}]
      assert decoded["options"]["precision_threshold"] == 92

      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("<html></html>",
             name: "test-name",
             dimensions: [%{width: 1280, height: 720}],
             precision_threshold: 92
           ) == :ok
  end

  test "Passing along Playwright options" do
    Req.Test.stub(ExSnappy, fn conn ->
      {:ok, body, _conn} = Plug.Conn.read_body(conn)
      decoded = Jason.decode!(body)

      assert decoded["playwright_options"] == %{
               "animations" => false,
               "caret" => "initial",
               "clip" => %{"height" => 120, "width" => 240, "x" => 10, "y" => 20},
               "dark_mode" => true,
               "full_page" => false,
               "locator" => ".my-element",
               "mask" => [".mask-me", "#secret"],
               "mask_color" => "#00FF00",
               "omit_background" => true,
               "scale" => "css"
             }

      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("<html></html>",
             name: "test-name",
             playwright_options: %{
               full_page: false,
               dark_mode: true,
               locator: ".my-element",
               animations: false,
               mask: [".mask-me", "#secret"],
               mask_color: "#00FF00",
               omit_background: true,
               clip: %{x: 10, y: 20, width: 240, height: 120},
               scale: "css",
               caret: "initial"
             }
           ) == :ok
  end

  test "Go Snappy not running" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.transport_error(conn, :econnrefused)
    end)

    assert ExSnappy.snap("<html></html>") ==
             {:error,
              %Req.TransportError{
                reason: :econnrefused
              }}
  end

  test "Shouldn't show and unused variable" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    html = "<html></html>"

    assert ExSnappy.snap(html) == :ok
  end
end
