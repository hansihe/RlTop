defmodule RlTools.LayoutView do
  use RlTools.Web, :view

  def title(nil), do: "Rocket League Top"
  def title(prefix), do: prefix <> " - Rocket League Top"
end
