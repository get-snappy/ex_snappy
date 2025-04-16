defmodule ExSnappyTest do
  use ExUnit.Case
  doctest ExSnappy

  test "Simple success" do
    Req.Test.stub(ExSnappy, fn conn ->
      Req.Test.text(conn, "OK")
    end)

    assert ExSnappy.snap("test-name", "<html></html>") == :ok
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
