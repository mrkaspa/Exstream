defmodule Exstreme.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exstreme,
      version: "0.0.3",
      description: description,
      package: package,
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description do
    """
    Exstreme is an implementation of a Stream Push data structure in the way of a runnable graph where all the nodes must be connected and process a message and pass the result to next node(s)
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.12", only: :dev},
      {:dialyxir, "~> 0.3", only: [:dev]},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end

  defp package do
    [# These are the default files included in the package
      name: :exstreme,
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Michel Perez"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/mrkaspa/exstreme"}
    ]
  end
end
