defmodule RlTools.Repo.Migrations.CreateFetchPass do
  use Ecto.Migration

  def change do
    create table(:fetchpasses) do
      add :time, :datetime
      add :end, :datetime
    end

  end
end
