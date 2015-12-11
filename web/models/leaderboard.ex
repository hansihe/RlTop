import EctoEnum
defenum RequestTypeEnum, skill: 0, stats: 1
defmodule RlTools.Leaderboard do
  use RlTools.Web, :model

  schema "leaderboards" do
    field :name, :string
    field :api_id, :string

    field :request_id, :string
    field :request_type, RequestTypeEnum

    timestamps
  end

  @required_fields ~w(request_id request_type name api_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:api_id)
  end
end
