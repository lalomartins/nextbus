defmodule NextBus.CLI do
  @spec main([String.t]) :: :ok
  def main(args) do
    :inets.start
    :ssl.start
    args
    |> parse_args()
    |> make_request()
  end

  defp parse_args(args) do
    {options, restargs, _invalid} = OptionParser.parse(args, [
      strict: [stop: :string]
    ])
    stop = cond do
      options[:stop] -> options[:stop]
      length(restargs) > 0 -> hd(restargs)
      true -> '13199'
    end
    [stop: stop]
  end

  defp make_request([stop: stop]) do
    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'https://transport.tallinn.ee/siri-stop-departures.php?stopid=#{stop}&time=', []}, [], [])
    IO.puts(body)
  end
end
