defmodule Talkie.Mixfile do
  use Mix.Project

  def project do
    [app: :walkietalkie,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: { Talkie, [] },
     applications: [:stateholder]]
  end

  defp deps do
    [{:stateholder, [path: "../../"]}]
  end
end
