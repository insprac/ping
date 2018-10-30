defmodule Ping.HTTPTest do
  use ExUnit.Case
  doctest Ping.HTTP

  test "greets the world" do
    assert Ping.HTTP.hello() == :world
  end
end
