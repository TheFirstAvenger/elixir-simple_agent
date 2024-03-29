defmodule SimpleAgent.Mixfile do
  use Mix.Project

  def project do
    [
      app: :simple_agent,
      version: "0.0.8",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: [readme: "README.md", main: "SimpleAgent", source_url: "https://github.com/TheFirstAvenger/elixir-simple_agent.git"]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.19", only: :dev, runtime: false}]
  end

  defp description do
    "A simplification/abstraction layer for the Agent module."
  end

  defp package do
    [contributors: ["Mike Binns"], licenses: ["MIT"], links: %{"GitHub" => "https://github.com/TheFirstAvenger/elixir-simple_agent.git"}]
  end
end
