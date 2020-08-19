defmodule Suomidev.SubmisisonsTest do
  use Suomidev.DataCase

  alias Suomidev.Submisisons

  describe "submissions" do
    alias Suomidev.Submisisons.Submission

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def submission_fixture(attrs \\ %{}) do
      {:ok, submission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Submisisons.create_submission()

      submission
    end

    test "list_submissions/0 returns all submissions" do
      submission = submission_fixture()
      assert Submisisons.list_submissions() == [submission]
    end

    test "get_submission!/1 returns the submission with given id" do
      submission = submission_fixture()
      assert Submisisons.get_submission!(submission.id) == submission
    end

    test "create_submission/1 with valid data creates a submission" do
      assert {:ok, %Submission{} = submission} = Submisisons.create_submission(@valid_attrs)
    end

    test "create_submission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Submisisons.create_submission(@invalid_attrs)
    end

    test "update_submission/2 with valid data updates the submission" do
      submission = submission_fixture()

      assert {:ok, %Submission{} = submission} =
               Submisisons.update_submission(submission, @update_attrs)
    end

    test "update_submission/2 with invalid data returns error changeset" do
      submission = submission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Submisisons.update_submission(submission, @invalid_attrs)

      assert submission == Submisisons.get_submission!(submission.id)
    end

    test "delete_submission/1 deletes the submission" do
      submission = submission_fixture()
      assert {:ok, %Submission{}} = Submisisons.delete_submission(submission)
      assert_raise Ecto.NoResultsError, fn -> Submisisons.get_submission!(submission.id) end
    end

    test "change_submission/1 returns a submission changeset" do
      submission = submission_fixture()
      assert %Ecto.Changeset{} = Submisisons.change_submission(submission)
    end
  end
end
