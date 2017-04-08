defmodule XiamiDailyRecommend.Mixfile do
  use Mix.Project

  def project do
    [app: :xiami_daily_recommend,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {XiamiDailyRecommend, []}]
  end

  defp deps do
    [{:cowboy, ">= 0.0.0"},
     {:httpoison, ">= 0.0.0"},
     {:plug, ">= 0.0.0"},
     {:poison, ">= 0.0.0"}]
  end
end
