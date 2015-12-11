import EctoEnum
defenum PlatformEnum, steam: 0, psn: 1

defmodule RlTools.Player do
  use RlTools.Web, :model

  schema "players" do

    field :name, :string
    
    field :full_id, :string
    field :player_id, :string
    field :platform, PlatformEnum

    belongs_to :latest_fetch, RlTools.FetchPass

    timestamps
  end

  @required_fields ~w(name platform player_id full_id)
  @optional_fields ~w(latest_fetch_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:full_id)
  end

  def platform_to_db(:steam), do: "Steam"
  def platform_to_db(:psn), do: "PSN"

  def platform_from_db("Steam"), do: :steam
  def platform_from_db("PSN"), do: :psn
end
