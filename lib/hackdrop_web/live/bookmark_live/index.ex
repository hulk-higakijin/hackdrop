defmodule HackdropWeb.BookmarkLive.Index do
  use HackdropWeb, :live_view

  alias Hackdrop.Libraries

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <.header>
        Bookmarks
        <:actions>
          <.button to={~p"/bookmarks/new"} link_type="live_redirect">
            <.icon name="hero-plus" /> New Bookmark
          </.button>
        </:actions>
      </.header>

      <div
        id="bookmarks"
        phx-update="stream"
        class="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-4"
      >
        <div :for={{id, bookmark} <- @streams.bookmarks} id={id} class="group flex flex-col">
          <a
            id={"bookmark-card-#{bookmark.id}"}
            href={bookmark.url}
            target="_blank"
            rel="noopener noreferrer"
            class="block flex-1 rounded-2xl transition duration-200 hover:-translate-y-1 focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
          >
            <.card class="h-full overflow-hidden transition duration-200 group-hover:border-primary/50 group-hover:shadow-xl">
              <.card_media
                src={bookmark.preview_url}
                alt=""
                aspect_ratio_class="aspect-video w-full object-cover transition duration-300 group-hover:scale-105"
              />
              <.card_content class="flex min-h-24 flex-col gap-2 p-5">
                <h2 class="line-clamp-2 text-lg font-semibold text-base-content">
                  {bookmark.title || "No title"}
                </h2>
                <p class="mt-auto line-clamp-2 break-all text-sm text-base-content/60">
                  {bookmark.url}
                </p>
              </.card_content>
            </.card>
          </a>
          <div class="flex items-center justify-end gap-3 px-2 pt-3 text-sm">
            <.link
              navigate={~p"/bookmarks/#{bookmark}/edit"}
              class="text-base-content/60 hover:text-primary"
            >
              Edit
            </.link>
            <.link
              phx-click={JS.push("delete", value: %{id: bookmark.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
              class="text-base-content/60 hover:text-error"
            >
              Delete
            </.link>
          </div>
        </div>
      </div>
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
