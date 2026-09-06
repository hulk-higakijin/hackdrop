defmodule HackdropWeb.BookmarkLiveTest do
  use HackdropWeb.ConnCase

  import Phoenix.LiveViewTest
  import Hackdrop.LibrariesFixtures

  @create_attrs %{url: "some url"}
  @update_attrs %{url: "some updated url"}
  @invalid_attrs %{url: nil}

  setup :register_and_log_in_user

  defp create_bookmark(%{scope: scope}) do
    bookmark = bookmark_fixture(scope)

    %{bookmark: bookmark}
  end

  describe "Index" do
    setup [:create_bookmark]

    test "lists all bookmarks", %{conn: conn, bookmark: bookmark} do
      {:ok, index_live, html} = live(conn, ~p"/bookmarks")

      assert html =~ "Bookmarks"
      assert has_element?(index_live, "#bookmark-card-#{bookmark.id}[href=\"#{bookmark.url}\"]")
    end

    test "saves new bookmark", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Bookmark")
               |> render_click()
               |> follow_redirect(conn, ~p"/bookmarks/new")

      assert render(form_live) =~ "New Bookmark"

      assert form_live
             |> form("#bookmark-form", bookmark: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bookmark-form", bookmark: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bookmarks")

      html = render(index_live)
      assert html =~ "Bookmark created successfully"
      assert html =~ "some url"
    end

    test "updates bookmark in listing", %{conn: conn, bookmark: bookmark} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#bookmarks-#{bookmark.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/bookmarks/#{bookmark}/edit")

      assert render(form_live) =~ "Edit Bookmark"

      assert form_live
             |> form("#bookmark-form", bookmark: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#bookmark-form", bookmark: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/bookmarks")

      html = render(index_live)
      assert html =~ "Bookmark updated successfully"
      assert html =~ "some updated url"
    end

    test "deletes bookmark in listing", %{conn: conn, bookmark: bookmark} do
      {:ok, index_live, _html} = live(conn, ~p"/bookmarks")

      assert index_live |> element("#bookmarks-#{bookmark.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bookmarks-#{bookmark.id}")
    end
  end
end
