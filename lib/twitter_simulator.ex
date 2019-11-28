defmodule TwitterSimulator do
  @moduledoc """
  Documentation for TwitterSimulator.
  """

  def start_simulation() do

    IO.puts(System.argv())
    IO.puts("Started Simulation")
    Server.start_link()
    CounterService.start_link()

    users = ["@bestuser", "@TweetOfGod", "@VSaurabh93"]
    clients = Enum.map(users, fn user ->
      # start client process and register user with server
      pid = Client.start_link(user) |> elem(1)
      GenServer.call(pid, :register)
      {user, pid}
     end)

    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :login)
    end)

    Enum.each(clients, fn {user, pid} ->
      users_to_subscribe = Enum.filter(users, fn other_user-> other_user != user end)
      GenServer.call(pid, {:subscribe, users_to_subscribe})
    end)

    Enum.each(clients, fn {_user, pid} ->
      GenServer.cast(pid, {:tweet, Utils.generate_random_tweet(users)})
    end)

    :timer.sleep(1000)

    Enum.each(clients, fn {_user, pid} ->
      #GenServer.cast(pid, {:querySubscribed})
      GenServer.cast(pid, {:queryMentions})
      #GenServer.cast(pid, {:queryHashtags, "#yoga"})
    end)

    :timer.sleep(1000)

    CounterService.get_statistics()

    # GenServer.call(Enum.at(clients, 0) |> elem(1), :logoff)
    # GenServer.call(Enum.at(clients, 0) |> elem(1), :delete_user)
    hashtags = ["#yoga", "#technology", "#science"]
    hashtags

    # IO.puts("Finished Simulation")
    # System.halt(0)
  end
end
