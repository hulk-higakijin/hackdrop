defmodule HackdropWeb.BookmarkLive.Index do
  use HackdropWeb, :live_view

  alias Hackdrop.Libraries

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Bookmarks
        <:actions>
          <.button variant="primary" navigate={~p"/bookmarks/new"}>
            <.icon name="hero-plus" /> New Bookmark
          </.button>
        </:actions>
      </.header>

      <.table
        id="bookmarks"
        rows={@streams.bookmarks}
        row_click={fn {_id, bookmark} -> JS.navigate(~p"/bookmarks/#{bookmark}") end}
      >
        <:col :let={{_id, bookmark}} label="Url">{bookmark.url}</:col>
        <:action :let={{_id, bookmark}}>
          <div class="sr-only">
            <.link navigate={~p"/bookmarks/#{bookmark}"}>Show</.link>
          </div>
          <.link navigate={~p"/bookmarks/#{bookmark}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, bookmark}}>
          <.link
            phx-click={JS.push("delete", value: %{id: bookmark.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Libraries.subscribe_bookmarks(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Bookmarks")
     |> stream(:bookmarks, list_bookmarks(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    bookmark = Libraries.get_bookmark!(socket.assigns.current_scope, id)
    {:ok, _} = Libraries.delete_bookmark(socket.assigns.current_scope, bookmark)

    {:noreply, stream_delete(socket, :bookmarks, bookmark)}
  end

  @impl true
  def handle_info({type, %Hackdrop.Libraries.Bookmark{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :bookmarks, list_bookmarks(socket.assigns.current_scope), reset: true)}
  end

  defp list_bookmarks(current_scope) do
    Libraries.list_bookmarks(current_scope)
  end
end
