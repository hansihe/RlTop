defmodule RlTools.LeaderboardValueTest do
  use RlTools.ModelCase

  alias RlTools.LeaderboardValue

  @valid_attrs %{value: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LeaderboardValue.changeset(%LeaderboardValue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LeaderboardValue.changeset(%LeaderboardValue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
