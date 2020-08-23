defmodule SuomidevWeb.Api.VoteControllerTest do
  use SuomidevWeb.ConnCase

  alias Suomidev.Submissions
  alias Suomidev.Submissions.Submission
  alias Suomidev.Votes
  alias Suomidev.Votes.Vote

  @create_attrs %{}

  def fixture(:vote) do
    {:ok, vote} = Votes.create_like(@create_attrs)

    vote
  end

  def fixture(:submission) do
    {:ok, submission} = Submissions.create_submission(%{
      "title" => "test title",
      "content_md" => "test content_md",
      "user_id" => 1,
    })

    submission
  end

  describe "create" do
    test "vote existing submission", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{current_user: %{id: 1}})
      %{submission: %Submission{id: id}} = create_submission()
      conn = post(conn, Routes.vote_path(conn, :vote_submission, id))
      assert json_response(conn, 200) == %{"ok" => true, "data" => %{"submission_id" => Integer.to_string(id)}}
    end

    test "vote fails on submission that does not exist", %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{current_user: %{id: 1}})
      %{id: id} = %{id: "-1"}
      conn = post(conn, Routes.vote_path(conn, :vote_submission, id))
      assert json_response(conn, 200) == %{"ok" => false, "message" => "submission does not exist"}
    end

    test "vote fails on existing submission when session is not active", %{conn: conn} do
      %{submission: %Submission{id: id}} = create_submission()
      conn = post(conn, Routes.vote_path(conn, :vote_submission, id))
      assert json_response(conn, 401) == %{"ok" => false}
    end
  end

  defp create_submission() do
    submission = fixture(:submission)
    %{submission: submission}
  end
end
