defmodule SuomidevWeb.SharedView do
  use SuomidevWeb, :view

  alias Suomidev.Accounts.User

  def upvote_svg(opts \\ [size: 14, stroke_width: 1.5]) do
    ~E"""
      <svg width="<%= opts[:size] %>" height="<%= opts[:size] %>" viewBox="0 0 14 14" xmlns="http://www.w3.org/2000/svg">
        <g fill="none" fill-rule="evenodd">
          <path d="M0 0h14v14H0z"/>
          <g class="upvote-svg" stroke-width="<%= opts[:stroke_width] %>">
            <path d="M7 2.817V12"/>
            <path stroke-linecap="square" d="M7 3L3 7M7 3l4 4"/>
          </g>
        </g>
      </svg>
    """
  end

  def comment_svg(opts \\ [size: 14, stroke_width: 1.5]) do
    ~E"""
      <svg width="<%= opts[:size] %>" height="<%= opts[:size] %>" viewBox="0 0 14 14" xmlns="http://www.w3.org/2000/svg">
        <g fill="none" fill-rule="evenodd">
          <path d="M0 0h14v14H0z"/>
          <path d="M12 3v7H7.744L4 12.054V10H2V3h10z" class="comment-svg" stroke-width="<%= opts[:stroke_width] %>"/>
        </g>
      </svg>
    """
  end

  def edit_svg(opts \\ [size: 14, stroke_width: 1.5]) do
    ~E"""
      <svg width="<%= opts[:size] %>" height="<%= opts[:size] %>" viewBox="0 0 14 14" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <defs>
          <path id="a" d="M0 0h14v14H0z"/>
        </defs>
        <g fill="none" fill-rule="evenodd">
          <mask id="b" fill="#fff">
            <use xlink:href="#a"/>
          </mask>
          <path d="M8 1v9.692l-2 2.943-2-2.943V1h4z" class="edit-svg" stroke-width="<%= opts[:stroke_width] %>" mask="url(#b)" transform="rotate(45 6 7.707)"/>
        </g>
      </svg>
    """
  end

  def is_submission_owner(%User{} = user, submission) do
    if user.id == submission.user_id do
      true
    else
      false
    end
  end

  def is_submission_owner(nil, _submission), do: false
end
