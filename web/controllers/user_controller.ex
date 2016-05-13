defmodule Commentor.UserController do
  use Commentor.Web, :controller
  # require IEx
  plug Ueberauth

  alias Commentor.User
  alias Ueberauth.Strategy.Helpers

  # def index(conn, _params) do
  #   users = Repo.all(User)
  #   render(conn, "index.html", users: users)
  # end

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Repo.get_by(User, uid: Integer.to_string(auth.extra.raw_info.user["id"]))

    if user do
      conn
      |> put_flash(:info, "Successfully authenticated.")
      |> put_session(:current_user, user)
      |> redirect(to: user_path(conn, :show, user))
    else
      user_params = %{uid: Integer.to_string(auth.extra.raw_info.user["id"]), email: auth.info.email}
      changeset = User.changeset(%User{}, user_params)
      
      case Repo.insert(changeset) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "Successfully authenticated.")
          |> put_session(:current_user, user)
          |> redirect(to: user_path(conn, :show, user))
        {:error, reason} ->
          conn
          |> put_flash(:error, reason)
          |> redirect(to: "/")
      end
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  # def delete(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(user)

  #   conn
  #   |> put_flash(:info, "User deleted successfully.")
  #   |> redirect(to: user_path(conn, :index))
  # end

  def trello(conn, _params) do
    user = Repo.get_by(User, uid: Integer.to_string(_params["sender"]["id"]))

    card_url = _params["pull_request"]["body"]

    url_contains_trello = Regex.match?(~r[trello], card_url)

    if url_contains_trello do
      card_list = String.split(card_url, "/")
      card_id = Enum.at(card_list, 4)
    end

    if user do
      key = System.get_env("TRELLO_KEY")
      token = System.get_env("TRELLO_TOKEN")

      pr_url = _params["pull_request"]["url"]
      comment = pr_url <> " " <> "\n sent from Commentor"

      HTTPoison.post "https://trello.com/1/cards/#{card_id}/actions/comments?key=#{key}&token=#{token}&text=#{comment}", ""
    end
  end
end
