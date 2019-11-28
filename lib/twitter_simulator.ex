defmodule TwitterSimulator do
  @moduledoc """
  Documentation for TwitterSimulator.
  """

  def start_simulation() do
    args = System.argv()
    if length(args) == 3 && Enum.at(args,2) == "zipf" do
      start_zipf_simulation(args)
    else
      start_simple_simulation(args)
    end
  end

  def start_simple_simulation(args) do

    num_users = Enum.at(args, 0) |> String.to_integer
    num_requests = Enum.at(args,1) |> String.to_integer

    IO.puts("Started Simulation")

    #start the server
    Server.start_link()
    CounterService.start_link()

    # create client actors and register them to server with their user id and pid
    users = Enum.map(1..num_users, fn x -> "@user_" <> to_string(x)end)
    clients = Enum.map(users, fn user ->
      # start client process and register user with server
      pid = Client.start_link(user) |> elem(1)
      GenServer.call(pid, :register)
      {user, pid}
     end)

     #login the clients
    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :login)
    end)


    #assign subscribers to each client. Number of subscribers is random
    Enum.each(clients, fn {user, pid} ->
      # assign random number of subscribers to each user
      users_to_subscribe = Enum.take_random(users, Enum.random(1..num_users))
      users_to_subscribe = Enum.filter(users_to_subscribe, fn other_user-> other_user != user end)
      GenServer.call(pid, {:subscribe, users_to_subscribe})
    end)

    # send randomly generated tweets
    Enum.each(clients, fn {_user, pid} ->
      Enum.each(1..num_requests, fn _x ->
      GenServer.cast(pid, {:tweet, Utils.generate_random_tweet(users)}) end)
    end)

    # sleep for a while as tweets are sent async
    :timer.sleep(1000)

    # query subscribed tweets and also retweet some tweets
    Enum.each(clients, fn {_user, pid} ->
      results = GenServer.call(pid, :querySubscribed)
      Enum.each(results, fn {user, tweets} ->
        if tweets != [] do
          GenServer.cast(pid, {:retweet, user, tweets |> Enum.at(0)})
        end
    end)
    end)

    # search mentions
    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :queryMentions)
    end)

    # search tweets by hashtags
    Enum.each(clients, fn {_user, pid} ->
      hashtags = ["#yoga", "#technology", "#science"]
      hashtag = Enum.take_random(hashtags, 1) |> Enum.at(0)
      GenServer.call(pid, {:queryHashtags, hashtag})
    end)

    # logoff user and delete account
    Enum.each(clients, fn {user, pid} ->
      GenServer.call(pid, :logoff)
      GenServer.call(pid, :delete_user)
    end)


    IO.puts("Finished Simulation")

    # print statistics
    CounterService.get_statistics()
    # System.halt(0)
  end

  def start_zipf_simulation(args) do

    num_users = Enum.at(args, 0) |> String.to_integer
    num_requests = Enum.at(args,1) |> String.to_integer

    IO.puts("Started Simulation")

    #start the server
    Server.start_link()
    CounterService.start_link()

    # create client actors and register them to server with their user id and pid
    users = Enum.map(1..num_users, fn x -> "@user_" <> to_string(x)end)
    clients = Enum.map(users, fn user ->
      # start client process and register user with server
      pid = Client.start_link(user) |> elem(1)
      GenServer.call(pid, :register)
      {user, pid}
     end)

     #login the clients
    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :login)
    end)


    #assign subscribers to each client using a zipf distribution.
    Enum.each(1..num_users, fn rank ->
      # assign subscriber count inverse to rank
      num = :math.ceil((num_users-1)/rank) |> trunc
      users_to_subscribe = Enum.take_random(users, num)
      {user, pid} = Enum.at(clients, rank-1)
      users_to_subscribe = Enum.filter(users_to_subscribe, fn other_user-> other_user != user end)
      GenServer.call(pid, {:subscribe, users_to_subscribe})
    end)

    # send tweets proportional to number of subscribers
    Enum.each(1..num_users, fn rank ->
      num = :math.ceil((num_users-1)/(rank*10)) |> trunc
      {_user, pid} = Enum.at(clients, rank-1)
      Enum.each(1..num, fn _x ->
        GenServer.cast(pid, {:tweet, Utils.generate_random_tweet(users)}) end)
    end)

    # sleep for a while as tweets are sent async
    :timer.sleep(1000)

    # query subscribed tweets and also retweet some tweets
    Enum.each(clients, fn {_user, pid} ->
      results = GenServer.call(pid, :querySubscribed)
      Enum.each(results, fn {user, tweets} ->
        if tweets != [] do
          GenServer.cast(pid, {:retweet, user, tweets |> Enum.at(0)})
        end
    end)
    end)

    # search mentions
    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :queryMentions)
    end)

    # search tweets by hashtags
    Enum.each(clients, fn {_user, pid} ->
      hashtags = ["#yoga", "#technology", "#science"]
      hashtag = Enum.take_random(hashtags, 1) |> Enum.at(0)
      GenServer.call(pid, {:queryHashtags, hashtag})
    end)

    # logoff user and delete account
    Enum.each(clients, fn {user, pid} ->
      GenServer.call(pid, :logoff)
      GenServer.call(pid, :delete_user)
    end)


    IO.puts("Finished Simulation")

    # print statistics
    CounterService.get_statistics()
    # System.halt(0)
  end
end
