defmodule XiamiDailyRecommend.Cache do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    current_date = Date.utc_today
    case :ets.lookup(:xiami, "date") do
      [{"date", cache_date}] -> assign(conn, :cache, cache_date == current_date)
      _ -> assign(conn, :cache, false)
    end
  end
end
