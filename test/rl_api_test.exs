defmodule RLApi.TestCase do
  use ExUnit.Case

  setup do
    session = RLApi.Session.make_from_config
    {:ok, session} = RLApi.login(session)
    {:ok, [session: session]}
  end

  test "call single proc GetRegionList directly", context do
    proc = %RLApi.Proc{proc: "GetRegionList", params: ["INTv2"]}
    procset = %RLApi.ProcSet{} |> RLApi.ProcSet.call(proc)
    procset_response = context[:session] |> RLApi.call_procset(procset)
    assert elem(procset_response, 0) == :ok
  end
end
