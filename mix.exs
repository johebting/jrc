defmodule Jrc.Mixfile do
  use Mix.Project

  @description """
  CLI client to fetch JIRA worklog
  """

  @version File.read!("VERSION") |> String.trim

  def project do
    [app: :jrc,
     version: @version,
     elixir: "~> 1.5",
     description: @description,
     package: package(),
     start_permanent: Mix.env == :prod,
     deps: deps(),
     escript: escript()]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{ :httpoison, "~> 0.13"},
     { :timex, "~> 3.1"},
     # Because tzdata > 0.1.8 cannot be embedded with escript
     {:tzdata, "== 0.1.8", override: true},
     { :poison, "~> 3.1"}]
  end

  defp package do
    [maintainers: ["Joseph Hebting"],
     licenses: ["GPLv3"],
     links: %{ "Github" => "https://github.com/johebting/jrc" }]
  end

  defp escript do
    [main_module: Jrc.CLI]
  end
end
