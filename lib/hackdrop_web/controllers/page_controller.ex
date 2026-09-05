defmodule HackdropWeb.PageController do
  use HackdropWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
