defmodule RlTools.PlayerTest do
  use RlTools.ModelCase

  alias RlTools.Player

  @valid_attrs %{id: "some content", name: "some content", platform: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end
