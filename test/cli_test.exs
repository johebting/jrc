defmodule CliTest do
    use ExUnit.Case
    doctest Jrc

    import Jrc.CLI, only: [ parse_args: 1 ]

    test ":help returned by option parsing with -h and --help options" do
        assert parse_args(["-h", "anything"]) == :help
        assert parse_args(["--help", "anything"]) == :help
    end
    test "only path, user and password parameters given" do
        assert parse_args(["jira.netapsys.fr", "username", "password"]) == { "jira.netapsys.fr", "username", "password", 7, :all_project }
    end
    test "only path, user, password and days_count parameters given" do
        assert parse_args(["jira.netapsys.fr", "username", "password", "3"]) == { "jira.netapsys.fr", "username", "password", 3, :all_project }
    end
    test "every parameters given" do
        assert parse_args(["jira.netapsys.fr", "username", "password", "4", "project"]) == { "jira.netapsys.fr", "username", "password", 4, "project" }
    end
    #test "count is defaulted if two values given" do
    #    assert parse_args(["user", "project"]) == { "user", "project", 4 }
    #end
end