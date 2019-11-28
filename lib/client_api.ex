defmodule ClientAPI do
  @moduledoc """
  Documentation for TwitterSimulator.
  """

  def register(users) do
    clients = Enum.map(users, fn user ->
      # start client process and register user with server
      pid = Client.start_link(user) |> elem(1)
      GenServer.call(pid, :register)
      {user, pid}
     end)
     clients
  end

  def login(clients) do
    Enum.each(clients, fn {_user, pid} ->
      GenServer.call(pid, :login)
    end)
  end

  #Give the user and users_list which the user wants to follow
  def subscribe(pid,users_to_subscribe) do
    GenServer.call(pid, {:subscribe, users_to_subscribe})
  end

  def tweet(pid, tweet) do
    GenServer.cast(pid, {:tweet, tweet})
  end

  def logoff(pid) do
    GenServer.call(pid, :logoff)
  end

  def queryMentions(pid) do
   GenServer.cast(pid, {:queryMentions})

  end

  def querySubscribed(pid) do
    GenServer.cast(pid, {:querySubscribed})
  end

  def queryHashtags(pid,hashtag) do
    GenServer.cast(pid, {:queryHashtags, hashtag})
  end

  def delete_user(pid) do
    GenServer.call(pid, :delete_user)
  end

end
