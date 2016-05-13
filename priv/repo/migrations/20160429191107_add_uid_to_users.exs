defmodule Commentor.Repo.Migrations.AddUidToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uid, :string
      add :trello_api, :string
    end
  end
end
