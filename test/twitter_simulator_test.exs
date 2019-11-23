defmodule TwitterSimulatorTest do
  use ExUnit.Case
  doctest TwitterSimulator

  test "greets the world" do
    assert TwitterSimulator.hello() == :world
  end
end
