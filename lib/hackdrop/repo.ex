defmodule Hackdrop.Repo do
  use Ecto.Repo,
    otp_app: :hackdrop,
    adapter: Ecto.Adapters.SQLite3
end
