defmodule Yeelight.MixProject do
  use Mix.Project

  def project do
    [
      app: :yeelight,
      licenses: "MIT License",
      version: "0.1.2",
      elixir: "~> 1.8",
      description: description(),
      name: "yeelight",
      links: %{"source" => "https://github.com/mbcrocci/yeelight-ex"},
      source_url: "https://github.com/mbcrocci/yeelight-ex",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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

  defp package() do
    [
      name: "yeelight",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mbcrocci/yeelight-ex"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
