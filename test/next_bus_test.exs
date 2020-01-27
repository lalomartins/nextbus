defmodule NextBusTest do
  use ExUnit.Case
  doctest NextBus

  test "parse empty schedule" do
    assert NextBus.parse_schedule("", nil) == []
  end

  test "parse valid schedule" do
    schedule = NextBus.parse_schedule("""
    Transport,RouteNum,ExpectedTimeInSeconds,ScheduleTimeInSeconds
    stop,13199
    bus,39,72716,72716,Veerenni
    bus,39,74276,74276,Veerenni
    """, nil)
    assert length(schedule) == 2
    [first, second] = schedule
    assert first[:transport] == "bus"
    assert second[:transport] == "bus"
    assert first[:expected] == 72716
  end

  test "filter schedule by route" do
    schedule = NextBus.parse_schedule("""
    Transport,RouteNum,ExpectedTimeInSeconds,ScheduleTimeInSeconds
    stop,13199
    bus,39,72716,72716,Veerenni
    bus,23,72256,72256,Liikuri
    bus,23,73816,73816,Liikuri
    bus,39,74276,74276,Veerenni
    bus,23,75376,75376,Liikuri
    """, "39")
    assert length(schedule) == 2
    [first, second] = schedule
    assert first[:transport] == "bus"
    assert second[:transport] == "bus"
    assert first[:expected] == 72716
    assert second[:route] == "39"
  end
end
