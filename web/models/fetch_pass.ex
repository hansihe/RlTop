defmodule RlTools.FetchPass do
  use RlTools.Web, :model

  schema "fetchpasses" do
    field :time, Ecto.DateTime
    field :end, Ecto.DateTime
  end

  @required_fields ~w(time)
  @optional_fields ~w(end)

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
