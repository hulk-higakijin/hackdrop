defmodule HackdropWeb.BookmarkLive.Index do
  use HackdropWeb, :live_view

  alias Hackdrop.Libraries

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <.header>
        Listing Bookmarks
        <:actions>
          <.button to={~p"/bookmarks/new"} link_type="live_redirect">
            <.icon name="hero-plus" /> New Bookmark
          </.button>
        </:actions>
      </.header>

      <.table
        id="bookmarks"
        rows={@streams.bookmarks}
        row_click={fn {_id, bookmark} -> JS.navigate(~p"/bookmarks/#{bookmark}") end}
      >
        <:col :let={{_id, bookmark}} label="Preview">
          <%= if bookmark.preview_url do %>
            <img
              id={"bookmark-preview-#{bookmark.id}"}
              src={bookmark.preview_url}
              alt=""
              class="h-12 w-20 rounded object-cover"
            />
          <% else %>
            <span class="text-sm text-base-content/50">No image</span>
          <% end %>
        </:col>
        <:col :let={{_id, bookmark}} label="Url">{bookmark.url}</:col>
        <:col :let={{_id, bookmark}} label="Title">{bookmark.title || "No title"}</:col>
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
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_path, URI.parse(uri).path)}
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
