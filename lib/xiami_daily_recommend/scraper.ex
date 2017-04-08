defmodule XiamiDailyRecommend.Scraper do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{cache: false}}=conn, _opts) do
    fetch_list()

    conn
  end
  def call(conn, _opts), do: conn

  defp fetch_list do
    token = case :ets.lookup(:xiami, "xiami_token") do
      [{"xiami_token", token}] -> token
      _ -> log_in()
    end

    response = HTTPoison.get!("http://www.xiami.com/song/playlist-default/cat/json",
      %{"Cookie" => "member_auth=" <> token})
    %HTTPoison.Response{status_code: 200, body: playlist} = response
    true = :ets.insert(:xiami, {"track_list", Poison.decode!(playlist)["data"]["trackList"]})
  end

  defp log_in do
    response = HTTPoison.post!("https://login.xiami.com/web/login",
      {:form, [email: Application.get_env(:xiami_daily_recommend, :usr),
               password: Application.get_env(:xiami_daily_recommend, :pwd),
               LoginButton: "登录"]},
      %{"User-Agent" => "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36",
        "Content-Type" => "application/x-www-form-urlencoded",
        "Referer" => "http://www.xiami.com/web/login"})
    %HTTPoison.Response{status_code: 302, headers: headers} = response
    [{_, token_str}] = Enum.filter(headers, fn
        {"Set-Cookie", "member_auth" <> _} -> true
        _ -> false
      end)
    token = String.slice(token_str, 12..-38)
    true = :ets.insert(:xiami, {"xiami_token", token})
    token
  end
end
