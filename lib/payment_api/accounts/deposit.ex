defmodule PaymentApi.Accounts.Deposit do
  alias PaymentApi.{Repo, Accounts.Operation}

  def call(params) do
    params
    |> Operation.call(&sum/2, :deposit)
    |> run_transaction()
  end

  def call(params, :no_transaction), do: Operation.call(params, &sum/2, :deposit)

  def call(params, :with_transaction), do: call(params)

  defp sum(balance, value), do: Decimal.add(balance, value)

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{update_balance_deposit: account}} -> {:ok, account}
    end
  end
end
