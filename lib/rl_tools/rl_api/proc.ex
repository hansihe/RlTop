defmodule RLApi.Proc do
  defstruct proc: nil, params: [], id: nil, response: nil, decoded: nil, decoder: nil

  def to_query(%RLApi.Proc{} = proc, proc_num) do
    query_head = "&Proc[]=#{URI.encode_www_form(proc.proc)}"
    reduce_fun = fn (val, acc) -> acc <> "&P#{proc_num}P[]=#{URI.encode_www_form(val)}" end
    proc.params |> Enum.reduce(query_head, reduce_fun)
  end

  def handle_response(%RLApi.Proc{} = proc, response) do
    line_decoder = fn line -> line |> URI.query_decoder |> Enum.map(&(&1)) end
    decoded_response = response |> String.split("\r\n") |> Enum.map(line_decoder)
    proc = %{proc | response: decoded_response}
    case proc.decoder do
      nil -> proc
      decoder -> decoder.(proc)
    end
  end

end
