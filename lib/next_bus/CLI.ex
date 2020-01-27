defmodule NextBus.CLI do
  @spec main([String.t]) :: :ok
  def main(args) do
    :inets.start
    :ssl.start
    args
    |> parse_args()
    |> NextBus.get_schedule()
    |> printout
  end

  defp parse_args(args) do
    {options, restargs, _invalid} = OptionParser.parse(args, [
      strict: [stop: :string, route: :string]
    ])
    stop = cond do
      options[:stop] -> options[:stop]
      length(restargs) > 0 -> hd(restargs)
      true -> '13199'
    end
    route = cond do
      options[:route] -> options[:route]
      length(restargs) > 1 -> hd(tl(restargs))
      true -> nil
    end
    [stop: stop, route: route]
  end

  defp format_time(time) when is_binary(time) do
    format_time String.to_integer time
  end

  defp format_time(time) do
    :io_lib.format("~b:~2..0b:~2..0b", [div(time, 3600), div(rem(time, 3600), 60), rem(time, 60)])
  end

  defp printout([]) do
    IO.puts("Sorry, no departures found.")
  end

  defp printout(departures) do
    IO.puts("Upcoming departures:")
    departures
    |> Enum.map(fn(%{transport: transport, route: route, expected: expected}) ->
      IO.puts("#{transport} #{route}: at #{format_time expected}")
    end)
  end
end
