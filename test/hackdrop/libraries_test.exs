defmodule Hackdrop.LibrariesTest do
  use Hackdrop.DataCase

  alias Hackdrop.Libraries

  describe "bookmarks" do
    alias Hackdrop.Libraries.Bookmark

    import Hackdrop.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hackdrop.LibrariesFixtures

    @invalid_attrs %{url: nil}

    test "list_bookmarks/1 returns all scoped bookmarks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      other_bookmark = bookmark_fixture(other_scope)
      assert Libraries.list_bookmarks(scope) == [bookmark]
      assert Libraries.list_bookmarks(other_scope) == [other_bookmark]
    end

    test "get_bookmark!/2 returns the bookmark with given id" do
      scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      other_scope = user_scope_fixture()
      assert Libraries.get_bookmark!(scope, bookmark.id) == bookmark
      assert_raise Ecto.NoResultsError, fn -> Libraries.get_bookmark!(other_scope, bookmark.id) end
    end

    test "create_bookmark/2 with valid data creates a bookmark" do
      valid_attrs = %{url: "some url"}
      scope = user_scope_fixture()

      assert {:ok, %Bookmark{} = bookmark} = Libraries.create_bookmark(scope, valid_attrs)
      assert bookmark.url == "some url"
      assert bookmark.user_id == scope.user.id
    end

    test "create_bookmark/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Libraries.create_bookmark(scope, @invalid_attrs)
    end

    test "update_bookmark/3 with valid data updates the bookmark" do
      scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      update_attrs = %{url: "some updated url"}

      assert {:ok, %Bookmark{} = bookmark} = Libraries.update_bookmark(scope, bookmark, update_attrs)
      assert bookmark.url == "some updated url"
    end

    test "update_bookmark/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)

      assert_raise MatchError, fn ->
        Libraries.update_bookmark(other_scope, bookmark, %{})
      end
    end

    test "update_bookmark/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Libraries.update_bookmark(scope, bookmark, @invalid_attrs)
      assert bookmark == Libraries.get_bookmark!(scope, bookmark.id)
    end

    test "delete_bookmark/2 deletes the bookmark" do
      scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      assert {:ok, %Bookmark{}} = Libraries.delete_bookmark(scope, bookmark)
      assert_raise Ecto.NoResultsError, fn -> Libraries.get_bookmark!(scope, bookmark.id) end
    end

    test "delete_bookmark/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      assert_raise MatchError, fn -> Libraries.delete_bookmark(other_scope, bookmark) end
    end

    test "change_bookmark/2 returns a bookmark changeset" do
      scope = user_scope_fixture()
      bookmark = bookmark_fixture(scope)
      assert %Ecto.Changeset{} = Libraries.change_bookmark(scope, bookmark)
    end
  end
end
