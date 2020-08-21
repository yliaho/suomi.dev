defmodule SuomidevWeb.Helpers do
  alias Suomidev.Accounts.User

  def get_user_id(%User{id: id}) do
    id
  end

  def get_user_id(_) do
    nil
  end
end
