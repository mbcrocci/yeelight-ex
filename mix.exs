defmodule Yeelight.MixProject do
  use Mix.Project

  def project do
    [
      app: :yeelight,
      licenses: "MIT License",
      version: "0.2.0",
      elixir: "~> 1.8",
      description: description(),
      name: "yeelight",
      links: %{"source" => "https://github.com/mbcrocci/yeelight-ex"},
      source_url: "https://github.com/mbcrocci/yeelight-ex",
      extra_applications: [:logger],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    []
  end

  defp description do
    """
    This is a library to comunicate with yeelight lamps using Elixir.
    For discovering the lights it uses a UPnP server that should be started using `Yeelight.Discover.start`
    """
  end

  defp package() do
    [
      name: "yeelight",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbcrocci/yeelight-ex"}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
