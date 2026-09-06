defmodule Hackdrop.Repo.Migrations.AddOgImageUrlToBookmarks do
  use Ecto.Migration

  def change do
    alter table(:bookmarks) do
      add :og_image_url, :string
    end
  end
end
