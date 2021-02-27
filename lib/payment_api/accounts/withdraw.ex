defmodule PaymentApi.Accounts.Withdraw do
  alias PaymentApi.{Repo, Accounts.Operation}

  def call(params) do
    params
    |> Operation.call(&subtract/2, :withdraw)
    |> run_transaction()
  end

  def call(params, :no_transaction), do: Operation.call(params, &subtract/2, :withdraw)

  def call(params, :with_transaction), do: call(params)

  defp subtract(balance, value), do: Decimal.sub(balance, value)

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{update_balance_withdraw: account}} -> {:ok, account}
    end
  end
end
