defmodule TwitterSimulator do
  @moduledoc """
  Documentation for TwitterSimulator.
  """

  def start_simulation() do

    args = System.argv()
    args = Enum.map(args, fn x -> String.to_integer(x)end)

    num_users = Enum.at(args, 0)
    num_requests = Enum.at(args,1)

    IO.puts("Started Simulation")
    Server.start_link()
    CounterService.start_link()

    users = Enum.map(1..num_users, fn x -> "@user_" <> to_string(x)end)
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
      # assign random number of subscribers to each user
      users_to_subscribe = Enum.take_random(users, Enum.random(1..num_users))
      users_to_subscribe = Enum.filter(users_to_subscribe, fn other_user-> other_user != user end)
      GenServer.call(pid, {:subscribe, users_to_subscribe})
    end)

    Enum.each(clients, fn {_user, pid} ->
      Enum.each(1..num_requests, fn _x ->
      GenServer.cast(pid, {:tweet, Utils.generate_random_tweet(users)}) end)
    end)

    :timer.sleep(1000)

    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, {:querySubscribed})
    end)

    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, {:queryMentions})
    end)

    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, {:queryHashtags, "#yoga"})
    end)

    CounterService.get_statistics()

    Enum.each(clients, fn {user, pid} ->
      GenServer.call(pid, :logoff)
      GenServer.call(pid, :delete_user)
    end)

    IO.puts("Finished Simulation")
    # System.halt(0)
  end
end
