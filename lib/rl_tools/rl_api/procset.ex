defmodule RLApi.ProcSet do
  defstruct procs: []

  def call(%RLApi.ProcSet{} = procset, %RLApi.Proc{} = proc) do
    %{procset | procs: [proc | procset.procs]}
  end

  def to_query(%RLApi.ProcSet{procs: procs}) do
    reduce_proc_query = fn ({val, num}, acc) -> acc <> RLApi.Proc.to_query(val, num) end
    procs |> Enum.with_index |> Enum.reduce("", reduce_proc_query)
  end

  def handle_response(%RLApi.ProcSet{procs: procs} = procset, response) do
    segments = String.split(response, "\r\n\r\n")
    apply_proc_response = fn {proc, segment} -> RLApi.Proc.handle_response(proc, segment) end
    %{procset | procs: procs |> Enum.zip(segments) |> Enum.map(apply_proc_response)}
  end
end

