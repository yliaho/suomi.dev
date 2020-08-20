defmodule Suomidev.Release do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:suomidev)

    path = Application.app_dir(:suomidev, "priv/repo/migrations")

    Ecto.Migrator.run(Suomidev.Repo, path, :up, all: true)

    :init.stop()
  end
end
