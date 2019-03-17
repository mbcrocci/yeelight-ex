defmodule Yeelight.MixProject do
  use Mix.Project

  def project do
    [
      app: :yeelight,
      version: "0.1.2",
      elixir: "~> 1.8",
      description: description(),
      name: "yeeligh-ex",
      licenses: ["MIT License"],
      links: %{"source" => "https://github.com/mbcrocci/yeelight-ex"},
      source_url: "https://github.com/mbcrocci/yeelight-ex",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp description() do
    "This is a library to comunicate with yeelight lamps using Elixir.\n" <>
      "For discovering the lights it uses a UPnP server that should be started using `Discover.start`"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.4"}
    ]
  end
end
