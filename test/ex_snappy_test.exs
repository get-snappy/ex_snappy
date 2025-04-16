defmodule ExSnappyTest do
  use ExUnit.Case
  doctest ExSnappy

  test "greets the world" do
    assert ExSnappy.hello() == :world
  end
end
