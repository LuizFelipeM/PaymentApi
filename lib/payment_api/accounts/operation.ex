defmodule PaymentApi.Accounts.Operation do
  alias Ecto.Multi
  alias PaymentApi.{Account}

  def call(%{"id" => id, "value" => value}, operation, operation_name) do
    account_transaction_name = get_account_transaction_name(operation_name)
    update_balance_transaction_name = get_update_balance_transaction_name(operation_name)

    Multi.new()
    |> Multi.run(account_transaction_name, get_account(id))
    |> Multi.run(
      update_balance_transaction_name,
      update_balance(value, operation, account_transaction_name)
    )
  end

  defp handle_cast({:ok, value}, balance, operation), do: operation.(balance, value)
  defp handle_cast(:error, _balance, _operation), do: {:error, "Invalid deposit value!"}

  defp get_account(id),
    do: fn repo, _changes ->
      case repo.get(Account, id) do
        nil -> {:error, "Account not found!"}
        account -> {:ok, account}
      end
    end

  defp update_balance(value, operation, key),
    do: fn repo, changes ->
      account = Map.get(changes, key)

      account
      |> exec_operation_values(value, operation)
      |> update_account(repo, account)
    end

  defp exec_operation_values(%Account{balance: balance}, value, operation) do
    value
    |> Decimal.cast()
    |> handle_cast(balance, operation)
  end

  defp update_account({:error, _reason} = error, _repo, _account), do: error

  defp update_account(value, repo, account) do
    account
    |> Account.changeset(%{balance: value})
    |> repo.update()
  end

  defp get_account_transaction_name(operation_name),
    do:
      "account_#{Atom.to_string(operation_name)}"
      |> String.to_atom()

  defp get_update_balance_transaction_name(operation_name),
    do:
      "update_balance_#{Atom.to_string(operation_name)}"
      |> String.to_atom()
end
