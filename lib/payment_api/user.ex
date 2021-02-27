defmodule PaymentApi.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset
  alias PaymentApi.Account

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_params [:password, :nickname, :email, :age, :name]

  schema "users" do
    field :name, :string
    field :age, :integer
    field :email, :string
    field :nickname, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_one :account, Account

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i)
    |> validate_length(:password, min: 8)
    # has a number
    |> validate_format(:password, ~r/[0-9]+/, message: "Password must contain a number")
    # has an upper case letter
    |> validate_format(:password, ~r/[A-Z]+/,
      message: "Password must contain an upper-case letter"
    )
    # has a lower case letter
    |> validate_format(:password, ~r/[a-z]+/, message: "Password must contain a lower-case letter")
    # Has a symbol
    |> validate_format(:password, ~r/[#\!\?&@\$%^&*\(\)]+/,
      message: "Password must contain a symbol"
    )
    |> validate_confirmation(:password)
    |> unique_constraint([:email])
    |> unique_constraint([:nickname])
    |> put_password_hash()
  end

  defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
