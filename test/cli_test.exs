defmodule CliTest do
    use ExUnit.Case
    doctest Jrc

    import Jrc.CLI, only: [ parse_args: 1 ]

    test ":help returned by option parsing with -h and --help options" do
        assert parse_args(["-h", "anything"]) == :help
        assert parse_args(["--help", "anything"]) == :help
    end
    test "only path, user and password parameters given" do
        assert parse_args(["--path", "jira.evilcorp.com", "--username", "toto", "--password", "azerty"]) == { "jira.evilcorp.com", "toto", "azerty", :all_project, 7 }
    end
    test "only days and project parameters given" do
        assert parse_args(["--days", "60", "--project", "linux"]) == { "jira.domain.com", "username", "password", "linux", 60 }
    end
    test "only no parameters given" do
        assert parse_args([]) == { "jira.domain.com", "username", "password", :all_project, 7 }
    end
end