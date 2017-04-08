defmodule XiamiDailyRecommend.Router do
  use Plug.Router
  use Plug.ErrorHandler
  import XiamiDailyRecommend.Decrypto

  plug XiamiDailyRecommend.Cache
  plug XiamiDailyRecommend.Scraper
  plug :match
  plug :dispatch

  get "/info/" do
    [{"track_list", track_list}] = :ets.lookup(:xiami, "track_list")
    
    body = Enum.map(track_list, fn(%{"title" => title, "artist_name" => artist_name, "pic" => pic}) ->
        %{"title" => title, "artist" => artist_name, "pic" => pic}
      end)
    |> Poison.encode!
    
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, body)
    |> halt
  end

  get "/track/:song_idx" do
    if Regex.match?(~r"^\d{1,2}$", song_idx) do
      id = String.to_integer(song_idx)

      [{"track_list", track_list}] = :ets.lookup(:xiami, "track_list")

      case Enum.at(track_list, id) do
        %{"location" => location} ->
          conn
          |> put_resp_header("Location", decrypt(location))
          |> resp(301, "redirect")
          |> halt
        _ ->
          conn
          |> send_resp(404, "not found")
          |> halt
      end
    else
      conn
      |> send_resp(404, "not found")
      |> halt
    end
  end

  match _ do
    conn
    |> send_resp(404, "not found")
    |> halt
  end

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "error")
  end
end
