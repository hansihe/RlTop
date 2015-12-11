defmodule RlTools.FetchPassTest do
  use RlTools.ModelCase

  alias RlTools.FetchPass

  @valid_attrs %{time: "2010-04-17 14:00:00"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FetchPass.changeset(%FetchPass{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FetchPass.changeset(%FetchPass{}, @invalid_attrs)
    refute changeset.valid?
  end
end
