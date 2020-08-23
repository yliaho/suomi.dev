defmodule SuomidevWeb.Api.VoteController do
  use SuomidevWeb, :controller

  alias Suomidev.Votes
  alias SuomidevWeb.Helpers

  plug Hammer.Plug,
    rate_limit: {"like:write", 60_000 * 30, 10},
    by: {:session, :current_user, &Helpers.get_user_id/1}

  def vote_submission(conn, %{"id" => id} = params) do
    case Bodyguard.permit(Votes, :create_like, conn.assigns.current_user, params) do
      :ok ->
        case Votes.create_like(%{
               "user_id" => conn.assigns.current_user.id,
               "submission_id" => id
             }) do
          {:ok, _struct} ->
            conn
            |> json(%{"ok" => true, "data" => %{"submission_id" => id}})

          {:error, _changeset} ->
            conn
            |> json(%{"ok" => false, "message" => "submission does not exist"})
        end

      _res ->
        conn
        |> put_status(401)
        |> json(%{"ok" => false})
    end
  end

  def unvote_submission(conn, %{"id" => id} = params) do
    case Bodyguard.permit(Votes, :delete_like, conn.assigns.current_user, params) do
      :ok ->
        res =
          Votes.delete_like(%{
            "user_id" => conn.assigns.current_user.id,
            "submission_id" => id
          })

        conn
        |> json(%{"ok" => true})

      _ ->
        conn
        |> put_status(401)
        |> json(%{"ok" => false})
    end
  end
end
