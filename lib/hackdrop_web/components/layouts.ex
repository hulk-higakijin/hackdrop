defmodule HackdropWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use HackdropWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :current_path, :string, default: ""

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.sidebar_shell
      for="sb-shell"
      class="overflow-hidden"
    >
      <:sidebar>
        <.sidebar_nav id="sb-shell" label="Main">
          <:header>
            <.icon name="hero-cube" class="w-5 h-5 shrink-0 text-primary-500" />
            <span class="pc-sidebar__brand">Hackdrop</span>
            <.sidebar_trigger for="sb-shell" class="ml-auto" />
          </:header>

          <.sidebar_item
            label="すべてのブックマーク"
            path="/bookmarks"
            link_type="a"
            icon="hero-bookmark"
            active={String.starts_with?(@current_path, "/bookmarks")}
          />

          <.sidebar_group label="Workspace">
            <.sidebar_item label="Dashboard" path="#" link_type="a" icon="hero-home" active />
            <.sidebar_item label="Inbox" path="#" link_type="a" icon="hero-inbox" badge="12" />
            <.sidebar_item label="Customers" path="#" link_type="a" icon="hero-users" />
          </.sidebar_group>

          <.sidebar_group label="Account">
            <.sidebar_item label="Settings" icon="hero-cog-6-tooth" open>
              <.sidebar_item label="Profile" path="#" link_type="a" />
              <.sidebar_item label="Billing" path="#" link_type="a" />
            </.sidebar_item>
            <.sidebar_item label="Team" path="#" link_type="a" icon="hero-user-group" />
          </.sidebar_group>

          <:footer>
            <.sidebar_item
              label="Sign out"
              path="#"
              link_type="a"
              icon="hero-arrow-left-start-on-rectangle"
            />
          </:footer>
        </.sidebar_nav>
      </:sidebar>

      <header class="flex items-center flex-none gap-3 px-4 border-b border-gray-200 h-14 dark:border-gray-800">
        <.sidebar_trigger for="sb-shell" target="mobile" />
        <span class="text-sm font-semibold">Dashboard</span>
      </header>
      <div class="p-4 text-sm text-gray-500 dark:text-gray-400">
        {render_slot(@inner_block)}
      </div>
    </.sidebar_shell>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
