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
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("<html></html>", name: "test-name", dimensions: []) == :ok
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
end
