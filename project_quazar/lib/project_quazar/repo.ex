defmodule ProjectQuazar.Repo do
  use Ecto.Repo,
    otp_app: :project_quazar,
    adapter: Ecto.Adapters.Postgres
end
