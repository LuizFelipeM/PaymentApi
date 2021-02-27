defmodule PaymentApiWeb.AccountsController do
  use PaymentApiWeb, :controller

  alias PaymentApi.Account
  alias PaymentApi.Accounts.Transactions.Response, as: TransactionResponse

  action_fallback PaymentApiWeb.FallbackController

  def deposit(conn, params) do
    with {:ok, %Account{} = account} <- PaymentApi.deposit(params) do
      conn
      |> put_status(:ok)
      |> render("update.json", account: account)
    end
  end

  def withdraw(conn, params) do
    with {:ok, %Account{} = account} <- PaymentApi.withdraw(params) do
      conn
      |> put_status(:ok)
      |> render("update.json", account: account)
    end
  end

  def transaction(conn, params) do
    task = Task.async(fn -> PaymentApi.transaction(params) end)

    with {:ok, %TransactionResponse{} = transaction} <- Task.await(task) do
      conn
      |> put_status(:ok)
      |> render("transaction.json", transaction: transaction)
    end
  end
end
