defmodule Suomidev.Votes.Like do
  use Ecto.Schema
  import Ecto.Changeset
  alias Suomidev.Accounts.User
  alias Suomidev.Submissions.Submission

  @primary_key false
  schema "likes" do
    belongs_to :user, User
    belongs_to :submission, Submission

    timestamps()
  end

  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :submission_id])
    |> cast_assoc(:user)
    |> cast_assoc(:submission)
    |> foreign_key_constraint(:likes_submission_id_fkey, name: :likes_submission_id_fkey)
  end
end
