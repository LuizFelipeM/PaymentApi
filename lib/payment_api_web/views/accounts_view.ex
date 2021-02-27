defmodule PaymentApiWeb.AccountsView do
  alias PaymentApi.Account
  alias PaymentApi.Accounts.Transactions.Response, as: TransactionResponse

  def render("update.json", %{
        account: %Account{
          id: id,
          balance: balance
        }
      }),
      do: %{
        message: "Successfully updated",
        account: %{
          id: id,
          balance: balance
        }
      }

  def render("transaction.json", %{
        transaction: %TransactionResponse{
          to_account: to_account,
          from_account: from_account
        }
      }),
      do: %{
        message: "Transaction done successfully",
        transaction: %{
          to: %{
            id: to_account.id,
            balance: to_account.balance
          },
          from: %{
            id: from_account.id,
            balance: from_account.balance
          }
        }
      }
end
