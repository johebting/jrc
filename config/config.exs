use Mix.Config

config :jrc, 
  jira_path: "jira.domain.com",
  username: "username",
  password: "password",
  default_project: :all_project,
  default_days_count: 7,
  max_daily_input: 8