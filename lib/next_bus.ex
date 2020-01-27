defmodule NextBus do
  @moduledoc """
  Documentation for NextBus.
  """

  @doc """
  Hello world.

  ## Examples

      iex> NextBus.hello()
      :world

  """
  def hello do
    :world
  end

  @spec get_schedule([stop: String.t, route: String.t]) :: any
  def get_schedule([stop: stop, route: route]) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'https://transport.tallinn.ee/siri-stop-departures.php?stopid=#{stop}&time=', []}, [], [])
    {:ok, sio} = body |> to_string |> StringIO.open
    departures = sio
    |> IO.binstream(:line)
    |> CSV.decode(validate_row_length: false, headers: true)
    |> get_departures(route)
    departures
  end

  defp get_departures(csv_data, nil) do
    csv_data
    |> Enum.filter(fn({:ok, row}) -> row["ExpectedTimeInSeconds"] end)
    |> Enum.map(fn({:ok, row}) -> %{
      transport: row["Transport"],
      route: row["RouteNum"],
      expected: row["ExpectedTimeInSeconds"],
      scheduled: row["ScheduleTimeInSeconds"],
    } end)
  end

  defp get_departures(csv_data, route) do
    get_departures(csv_data, nil)
    |> Enum.filter(fn(departure) -> departure[:route] == route end)
  end
end
