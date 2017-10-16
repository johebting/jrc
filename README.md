# JRC

CLI client to fetch JIRA worklog - written in Elixir.

**JRC** stands for : **J**IRA **R**eport **C**lient

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jrc` to your list of dependencies in `mix.exs`:

First, clone the project:
```bash
git clone git@github.com:johebting/jrc.git
```

Make sure you have a recent version of `elixir` and get project dependencies:
```bash
mix deps.get
```

Then, generate the executable file:
```bash
mix escript.build
```

This should create a `jrc` file in your project folder.

# Usage

You can fetch result by passing server path and credentials by arguments :
```bash
$ jrc --path "jira.host.com" --username "username" --password "password"
```
Or by editing the `config/config.exs` file :
```bash
config :jrc, 
  jira_path: "jira.host.com",
  username: "username",
  password: "password",
  default_project: :all_project,
  default_days_count: 7
```