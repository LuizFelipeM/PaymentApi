defmodule PaymentApi.Accounts.Transaction do
  alias Ecto.Multi
  alias PaymentApi.Repo
  alias PaymentApi.Accounts.Transactions.Response, as: TransactionResponse
  alias PaymentApi.Accounts.{Withdraw, Deposit}

  def call(%{"from" => from, "to" => to, "value" => value}) do
    withdraw_params = build_params(from, value)
    deposit_params = build_params(to, value)

    Multi.new()
    |> Multi.merge(fn _changes -> Withdraw.call(withdraw_params, :no_transaction) end)
    |> Multi.merge(fn _changes -> Deposit.call(deposit_params, :no_transaction) end)
    |> run_transaction()
  end

  defp build_params(id, value) do %{"id" => id, "value" => value} end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{update_balance_deposit: to_account, update_balance_withdraw: from_account}} -> {:ok, TransactionResponse.build(from_account, to_account)}
    end
  end
end
