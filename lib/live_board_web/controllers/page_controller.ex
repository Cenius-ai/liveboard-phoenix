defmodule LiveBoardWeb.PageController do
  use LiveBoardWeb, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: "/dashboard")
    else
      redirect(conn, to: "/login")
    end
  end
end
