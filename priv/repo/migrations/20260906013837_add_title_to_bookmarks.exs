defmodule Hackdrop.Repo.Migrations.AddTitleToBookmarks do
  use Ecto.Migration

  def change do
    alter table(:bookmarks) do
      add :title, :string
    end
  end
end
