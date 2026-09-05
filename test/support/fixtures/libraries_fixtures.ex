defmodule Hackdrop.LibrariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hackdrop.Libraries` context.
  """

  @doc """
  Generate a bookmark.
  """
  def bookmark_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        url: "some url"
      })

    {:ok, bookmark} = Hackdrop.Libraries.create_bookmark(scope, attrs)
    bookmark
  end
end
