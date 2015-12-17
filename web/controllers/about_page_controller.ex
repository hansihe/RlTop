defmodule RlTools.AboutPageController do
  use RlTools.Web, :controller

  def about(conn, _params) do
    render conn, "about.html"
  end
end
