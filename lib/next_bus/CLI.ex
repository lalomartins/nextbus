defmodule NextBus.CLI do
  @spec main([String.t]) :: :ok
  def main(args) do
    :inets.start
    :ssl.start
    args
    |> parse_args()
    |> NextBus.get_schedule()
    |> IO.inspect
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
end
