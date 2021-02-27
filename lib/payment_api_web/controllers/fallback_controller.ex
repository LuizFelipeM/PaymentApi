defmodule PaymentApiWeb.FallbackController do
  use PaymentApiWeb, :controller

  def call(conn, {:error, result}) do
    conn
    |> put_status(:bad_request)
    |> put_view(PaymentApiWeb.ErrorView)
    |> render("400.json", result: result)
  end
end
