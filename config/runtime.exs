import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/whatsapp start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :whatsapp, WhatsappWeb.Endpoint, server: true
end

config :whatsapp, WhatsappWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :whatsapp, Whatsapp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "ciccio-chat.onrender.com"

  # Configura Resend per email in production
  config :whatsapp, Whatsapp.Mailer,
    adapter: Swoosh.Adapters.Finch,
    finch_name: Whatsapp.Finch,
    base_url: "https://api.resend.com",
    api_key: System.get_env("RESEND_API_KEY")

  config :whatsapp, Whatsapp.Accounts.UserNotifier,
    from_email: System.get_env("MAILER_FROM_EMAIL") || "noreply@ciccio-chat.com",
    from_name: System.get_env("MAILER_FROM_NAME") || "Ciccio Chat"

  config :whatsapp, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :whatsapp, WhatsappWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base
end
