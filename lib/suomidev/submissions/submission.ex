defmodule Suomidev.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoLtree.LabelTree, as: Ltree
  alias Suomidev.Accounts.User
  alias Suomidev.Votes.Like

  schema "submissions" do
    field(:type, :string)
    field(:path, Ltree)
    field(:title, :string)
    field(:content_md, :string)
    field(:content_html, :string)
    field(:cache_like_count, :integer)
    field(:cache_comment_count, :integer)
    field(:flag, :string)
    has_many(:likes, Like)
    belongs_to(:user, User)
    belongs_to(:parent, Submission, defaults: nil)
    field(:url, :string)

    field(:current_user_liked, :boolean, virtual: true)
    field(:more_comment, :integer, virtual: true)
    field(:score, :integer, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(submission, %{"title" => _} = attrs) do
    submission
    |> cast(attrs, [:type, :title, :content_md, :content_html, :user_id, :url])
    |> put_change(:type, "post")
    |> validate_required([:type, :title, :user_id,])
  end

  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:content_md, :content_html, :path, :user_id, :parent_id])
    |> validate_length(:content_html, min: 1)
    |> put_change(:type, "comment")
    |> validate_required([:content_md, :parent_id])
  end
end
