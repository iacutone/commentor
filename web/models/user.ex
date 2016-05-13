defmodule Commentor.User do
  use Commentor.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :pivotal_api, :string
    field :uid, :string
    field :trello_api, :string

    timestamps
  end

  @required_fields ~w(uid email)
  @optional_fields ~w(pivotal_api trello_api)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:uid)
    |> unique_constraint(:email)
  end
end
