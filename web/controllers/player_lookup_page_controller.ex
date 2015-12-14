defmodule RlTools.PlayerLookupPageController do
  use RlTools.Web, :controller

  @vanity_url_api_base "http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/"

  def index(conn, _params) do
    conn
    |> render "index.html", %{csrf_token: get_csrf_token}
  end

  def remove_protocol("https://" <> body), do: body
  def remove_protocol("http://" <> body), do: body
  def remove_protocol(body), do: body

  def platform_to_atom("steam"), do: :steam
  def platform_to_atom("psn"), do: :psn

  def steam_url_to_id("steamcommunity.com/profiles/" <> id), do: {:ok, id}
  def steam_url_to_id("steamcommunity.com/id/" <> vanity_id) do
    conf = Application.get_env(:rl_tools, :steam_web_api)
    query = URI.encode_query %{
      key: conf[:key],
      vanityurl: vanity_id
    }
    case HTTPoison.get(@vanity_url_api_base <> "?" <> query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parsed = Poison.Parser.parse!(body)
        IO.inspect parsed
        case parsed do
          %{"response" => %{"success" => 1, "steamid" => id}} -> {:ok, id}
          %{"response" => %{"success" => 42}} -> {:error, :no_user}
          _ -> {:error, :steam_response}
        end
      _ -> {:error, :steam_error}
    end
  end
  def steam_url_to_id(_), do: {:error, :malformed}

  def value_to_id(:psn, value), do: {:ok, value}
  def value_to_id(:steam, value) do
    value_body = remove_protocol(value)
    steam_url_to_id(value_body)
  end

  def lookup(conn, %{"platform" => platform, "value" => value}) do
    platform_atom = platform_to_atom(platform)
    resp = value_to_id(platform_atom, value)
    case resp do
      {:ok, id} -> text conn, id
      {:error, _} -> text conn, "error"
    end
  end
end
