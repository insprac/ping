defmodule Ping.MonitorTest do
  use ExUnit.Case
  doctest Ping.Monitor

  test "greets the world" do
    assert Ping.Monitor.hello() == :world
  end
end
