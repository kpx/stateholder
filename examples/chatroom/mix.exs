defmodule ChatRoom.Mixfile do
  use Mix.Project

  def project do
    [app: :chatroom,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [mod: { ChatRoom, [] },
     applications: [:stateholder]]
  end

  defp deps do
    [{:stateholder, [path: "../../"]},
     {:poison, "~> 2.0"}]
  end
end
