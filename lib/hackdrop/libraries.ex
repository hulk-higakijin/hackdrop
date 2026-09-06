defmodule Hackdrop.Libraries do
  @moduledoc """
  The Libraries context.
  """

  import Ecto.Query, warn: false
  alias Hackdrop.Repo

  alias Hackdrop.Libraries.Bookmark
  alias Hackdrop.Libraries.Ogp
  alias Hackdrop.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any bookmark changes.

  The broadcasted messages match the pattern:

    * {:created, %Bookmark{}}
    * {:updated, %Bookmark{}}
    * {:deleted, %Bookmark{}}

  """
  def subscribe_bookmarks(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Hackdrop.PubSub, "user:#{key}:bookmarks")
  end

  defp broadcast_bookmark(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Hackdrop.PubSub, "user:#{key}:bookmarks", message)
  end

  @doc """
  Returns the list of bookmarks.

  ## Examples

      iex> list_bookmarks(scope)
      [%Bookmark{}, ...]

  """
  def list_bookmarks(%Scope{} = scope) do
    Repo.all_by(Bookmark, user_id: scope.user.id)
  end

  @doc """
  Gets a single bookmark.

  Raises `Ecto.NoResultsError` if the Bookmark does not exist.

  ## Examples

      iex> get_bookmark!(scope, 123)
      %Bookmark{}

      iex> get_bookmark!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_bookmark!(%Scope{} = scope, id) do
    Repo.get_by!(Bookmark, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a bookmark.

  ## Examples

      iex> create_bookmark(scope, %{field: value})
      {:ok, %Bookmark{}}

      iex> create_bookmark(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bookmark(%Scope{} = scope, attrs) do
    with {:ok, bookmark = %Bookmark{}} <-
           %Bookmark{}
           |> bookmark_changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_bookmark(scope, {:created, bookmark})
      {:ok, bookmark}
    end
  end

  @doc """
  Updates a bookmark.

  ## Examples

      iex> update_bookmark(scope, bookmark, %{field: new_value})
      {:ok, %Bookmark{}}

      iex> update_bookmark(scope, bookmark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bookmark(%Scope{} = scope, %Bookmark{} = bookmark, attrs) do
    true = bookmark.user_id == scope.user.id

    with {:ok, bookmark = %Bookmark{}} <-
           bookmark
           |> bookmark_changeset(attrs, scope)
           |> Repo.update() do
      broadcast_bookmark(scope, {:updated, bookmark})
      {:ok, bookmark}
    end
  end

  @doc """
  Deletes a bookmark.

  ## Examples

      iex> delete_bookmark(scope, bookmark)
      {:ok, %Bookmark{}}

      iex> delete_bookmark(scope, bookmark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bookmark(%Scope{} = scope, %Bookmark{} = bookmark) do
    true = bookmark.user_id == scope.user.id

    with {:ok, bookmark = %Bookmark{}} <-
           Repo.delete(bookmark) do
      broadcast_bookmark(scope, {:deleted, bookmark})
      {:ok, bookmark}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bookmark changes.

  ## Examples

      iex> change_bookmark(scope, bookmark)
      %Ecto.Changeset{data: %Bookmark{}}

  """
  def change_bookmark(%Scope{} = scope, %Bookmark{} = bookmark, attrs \\ %{}) do
    true = bookmark.user_id == scope.user.id

    Bookmark.changeset(bookmark, attrs, scope)
  end

  defp bookmark_changeset(%Bookmark{} = bookmark, attrs, %Scope{} = scope) do
    changeset = Bookmark.changeset(bookmark, attrs, scope)

    if changeset.valid? do
      preview_url = fetch_preview_url(Ecto.Changeset.get_field(changeset, :url))
      Ecto.Changeset.put_change(changeset, :preview_url, preview_url)
    else
      changeset
    end
  end

  defp fetch_preview_url(url) do
    case Ogp.fetch_image_url(url) do
      {:ok, preview_url} -> preview_url
      :error -> nil
    end
  end
end
