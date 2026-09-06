defmodule HackdropWeb.BookmarkLive.Show do
  use HackdropWeb, :live_view

  alias Hackdrop.Libraries

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <.header>
        Bookmark {@bookmark.id}
        <:subtitle>This is a bookmark record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/bookmarks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/bookmarks/#{@bookmark}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit bookmark
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Url">{@bookmark.url}</:item>
        <:item title="Preview">
          <%= if @bookmark.preview_url do %>
            <img
              id="bookmark-preview"
              src={@bookmark.preview_url}
              alt=""
              class="max-h-64 max-w-full rounded-lg object-cover"
            />
          <% else %>
            <span class="text-sm text-base-content/50">No image available</span>
          <% end %>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Libraries.subscribe_bookmarks(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Bookmark")
     |> assign(:bookmark, Libraries.get_bookmark!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_path, URI.parse(uri).path)}
  end

  @impl true
  def handle_info(
        {:updated, %Hackdrop.Libraries.Bookmark{id: id} = bookmark},
        %{assigns: %{bookmark: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :bookmark, bookmark)}
  end

  def handle_info(
        {:deleted, %Hackdrop.Libraries.Bookmark{id: id}},
        %{assigns: %{bookmark: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current bookmark was deleted.")
     |> push_navigate(to: ~p"/bookmarks")}
  end

  def handle_info({type, %Hackdrop.Libraries.Bookmark{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
