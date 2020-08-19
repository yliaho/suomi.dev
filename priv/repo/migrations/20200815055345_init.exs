defmodule Suomidev.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION ltree", "DROP EXTENSION ltree")

    # USERS
    create table(:users) do
      add :username, :string, size: 18, null: false
      # emails apparently can be a max of 320 characters in total.
      add :email, :string, size: 320, null: false
      add :provider, :string, null: false
      add :token, :string
      add :prefers_color_scheme, :string, size: 32
      add :flag, :string

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
    create index(:users, [:provider])

    # SUBMISSIONS
    create table(:submissions) do
      add :type, :string, null: false
      add :path, :ltree
      add :title, :string, size: 120
      add :content_md, :string, size: 3_000
      add :content_html, :string, size: 3_000
      add :url, :string, size: 2_083
      add :user_id, references(:users, on_delete: :delete_all)
      add :cache_like_count, :integer, default: 0
      add :cache_comment_count, :integer, default: 0
      add :flag, :string
      add :parent_id, references(:submissions, on_delete: :delete_all, null: true), null: true

      timestamps()
    end

    create index(:submissions, [:path], using: :gist)
    create index(:submissions, [:type])
    create index(:submissions, [:flag])
    create index(:submissions, [:parent_id])
    create index(:submissions, [:user_id])

    # LIKES
    create table(:likes, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :submission_id, references(:submissions, on_delete: :delete_all)

      timestamps()
    end

    create index(:likes, [:user_id])
    create index(:likes, [:submission_id])
    create unique_index(:likes, [:user_id, :submission_id], name: :user_id_submission_id_idx)

    # NOTIFICATIONS
    create table(:notifications) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :from_submission_id, references(:submissions, on_delete: :delete_all)
      add :root_submission_id, references(:submissions, on_delete: :delete_all)

      timestamps()
    end

    create index(:notifications, [:from_submission_id])
    create index(:notifications, [:root_submission_id])

    create unique_index(:notifications, [:from_submission_id, :root_submission_id],
             name: :from_submission_id_root_submission_id_idx
           )
  end
end
