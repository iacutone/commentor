defmodule Commentor.ApiController do
  use Commentor.Web, :controller

  alias Commentor.User

  require IEx

  def trello(conn, _params) do
    user = Repo.get_by(User, uid: Integer.to_string(_params["sender"]["id"]))

    card_url = _params["pull_request"]["body"]

    if card_url do
      url_contains_trello = Regex.match?(~r[trello], card_url)
    end

    if url_contains_trello do
      card_list = String.split(card_url, "/")
      card_id = Enum.at(card_list, 4)
    end

    if user && card_url && card_id do
      key = System.get_env("TRELLO_KEY")
      token = System.get_env("TRELLO_TOKEN")

      pr_url = _params["pull_request"]["url"]
      comment_url = String.replace(pr_url, "https://", "")
      comment = comment_url <> " " <> " sent from Commentor"

      HTTPoison.post "https://trello.com/1/cards/#{card_id}/actions/comments?key=#{key}&token=#{token}&text=#{comment}", ""
    end

    conn
      |> put_status(:ok)
      # |> json( %{ resp_type: :success} )
  end
end
