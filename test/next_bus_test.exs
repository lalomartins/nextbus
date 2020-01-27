defmodule NextBusTest do
  use ExUnit.Case
  doctest NextBus

  test "greets the world" do
    assert NextBus.hello() == :world
  end
end
