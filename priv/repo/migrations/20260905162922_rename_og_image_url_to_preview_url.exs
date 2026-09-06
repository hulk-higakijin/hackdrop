defmodule Hackdrop.Repo.Migrations.RenameOgImageUrlToPreviewUrl do
  use Ecto.Migration

  def change do
    rename table(:bookmarks), :og_image_url, to: :preview_url
  end
end
