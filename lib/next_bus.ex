defmodule NextBus do
  @moduledoc """
  Get and parse schedules from Tallinn transport authority
  """

  @type departure :: %{
    transport: String.t,
    route: String.t,
    expected: integer,
    scheduled: integer,
  }

  @spec get_schedule([stop: String.t, route: String.t]) :: [departure]
  def get_schedule([stop: stop, route: route]) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'https://transport.tallinn.ee/siri-stop-departures.php?stopid=#{stop}&time=', []}, [], [])
    body |> to_string |> parse_schedule(route)
  end

  @spec parse_schedule(String.t, String.t) :: [departure]
  def parse_schedule(schedule, route) do
      {:ok, sio} = schedule |> StringIO.open
      sio
      |> IO.binstream(:line)
      |> CSV.decode(validate_row_length: false, headers: true)
      |> get_departures(route)
  end

  defp get_departures(csv_data, nil) do
    csv_data
    |> Enum.filter(fn({:ok, row}) -> row["ExpectedTimeInSeconds"] end)
    |> Enum.map(fn({:ok, row}) -> %{
      transport: row["Transport"],
      route: row["RouteNum"],
      expected: String.to_integer(row["ExpectedTimeInSeconds"]),
      scheduled: String.to_integer(row["ScheduleTimeInSeconds"]),
    } end)
  end

  defp get_departures(csv_data, route) do
    get_departures(csv_data, nil)
    |> Enum.filter(fn(departure) -> departure[:route] == route end)
  end
end
