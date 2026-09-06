defmodule HackdropWeb.BookmarkLive.Form do
  use HackdropWeb, :live_view

  alias Hackdrop.Libraries
  alias Hackdrop.Libraries.Bookmark

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} current_path={@current_path}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage bookmark records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="bookmark-form" phx-change="validate" phx-submit="save">
        <.field field={@form[:url]} type="text" label="Url" />
        <footer>
          <.button phx-disable-with="Saving..." color="primary">Save Bookmark</.button>
          <.button
            to={return_path(@current_scope, @return_to, @bookmark)}
            link_type="live_redirect"
          >Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply, assign(socket, :current_path, URI.parse(uri).path)}
  end

  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    bookmark = Libraries.get_bookmark!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Bookmark")
    |> assign(:bookmark, bookmark)
    |> assign(:form, to_form(Libraries.change_bookmark(socket.assigns.current_scope, bookmark)))
  end

  defp apply_action(socket, :new, _params) do
    bookmark = %Bookmark{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Bookmark")
    |> assign(:bookmark, bookmark)
    |> assign(:form, to_form(Libraries.change_bookmark(socket.assigns.current_scope, bookmark)))
  end

  @impl true
  def handle_event("validate", %{"bookmark" => bookmark_params}, socket) do
    changeset =
      Libraries.change_bookmark(
        socket.assigns.current_scope,
        socket.assigns.bookmark,
        bookmark_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bookmark" => bookmark_params}, socket) do
    save_bookmark(socket, socket.assigns.live_action, bookmark_params)
  end

  defp save_bookmark(socket, :edit, bookmark_params) do
    case Libraries.update_bookmark(
           socket.assigns.current_scope,
           socket.assigns.bookmark,
           bookmark_params
         ) do
      {:ok, bookmark} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmark updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bookmark)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bookmark(socket, :new, bookmark_params) do
    case Libraries.create_bookmark(socket.assigns.current_scope, bookmark_params) do
      {:ok, bookmark} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bookmark created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bookmark)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _bookmark), do: ~p"/bookmarks"
end
