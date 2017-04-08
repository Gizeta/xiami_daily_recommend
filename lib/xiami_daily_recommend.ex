defmodule XiamiDailyRecommend do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:xiami_daily_recommend, :cowboy_port, 8081)
    :ets.new(:xiami, [:set, :public, :named_table])

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, XiamiDailyRecommend.Router, [], port: port)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
