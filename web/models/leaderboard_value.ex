defmodule RlTools.LeaderboardValue do
  use RlTools.Web, :model

  schema "leaderboardvalues" do
    field :value, :integer
    field :has_changed, :boolean
    field :value_num, :integer
    field :time, Ecto.DateTime

    belongs_to :player, RlTools.Player
    belongs_to :leaderboard, RlTools.Leaderboard
    belongs_to :fetch_pass, RlTools.FetchPass
  end

  @required_fields ~w(value player_id leaderboard_id time value_num has_changed)
  @optional_fields ~w(fetch_pass_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
