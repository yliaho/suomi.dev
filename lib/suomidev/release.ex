defmodule Suomidev.Release do
  def migrate do
    path = Application.app_dir(:suomidev, "priv/repo/migrations")

    Ecto.Migrator.run(Suomidev.Repo, path, :up, all: true)

    :init.stop()
  end
end
