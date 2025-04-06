defmodule Elixurl.Repo do
  use Ecto.Repo,
    otp_app: :elixurl,
    adapter: Ecto.Adapters.Postgres
end
