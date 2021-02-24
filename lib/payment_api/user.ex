defmodule PaymantApi.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @required_params [:password, :nickname, :email, :age, :name]

  schema "users" do
    field :name, :string
    field :age, :integer
    field :email, :string
    field :nickname, :string
    field :password, :string, virtual: true
    field :password_hash, :string
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/[0-9]+/, message: "Password must contain a number") # has a number
    |> validate_format(:password, ~r/[A-Z]+/, message: "Password must contain an upper-case letter") # has an upper case letter
    |> validate_format(:password, ~r/[a-z]+/, message: "Password must contain a lower-case letter") # has a lower case letter
    |> validate_format(:password, ~r/[#\!\?&@\$%^&*\(\)]+/, message: "Password must contain a symbol") # Has a symbol
    |> validate_confirmation(:password)
    |> unique_constraint([:email])
    |> unique_constraint([:nickname])
    |> put_password_hash()
  end

  defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}}) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
