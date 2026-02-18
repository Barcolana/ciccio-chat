defmodule Whatsapp.Repo do
  use Ecto.Repo,
    otp_app: :whatsapp,
    adapter: Ecto.Adapters.Postgres
end
