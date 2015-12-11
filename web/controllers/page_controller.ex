defmodule RlTools.PageController do
  use RlTools.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
