defmodule RlTools.LeaderboardTest do
  use RlTools.ModelCase

  alias RlTools.Leaderboard

  @valid_attrs %{request_id: "some content", request_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Leaderboard.changeset(%Leaderboard{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Leaderboard.changeset(%Leaderboard{}, @invalid_attrs)
    refute changeset.valid?
  end
end
