defmodule ClientTest do
  use ExUnit.Case

  test "Register User" do
    Server.start_link()
    user = "@bestuser"
    #start a client
    {_, pid} = Client.start_link(user)
    #register the client
    GenServer.call(pid, :register)
    # Use Server backend API to check if user is registered
    assert TwitterEngine.get_user_pid(user) == pid
  end

  test "Delete User" do
    Server.start_link()
    user = "@bestuser"
    #start a client
    {_, pid} = Client.start_link(user)
    #register the client
    GenServer.call(pid, :register)
    # Use Server backend API to check if user is registered
    assert TwitterEngine.get_user_pid(user) == pid
    # Delete the user
    GenServer.call(pid, :delete_user)
    # Use Server backend API to check if user is deleted
    assert TwitterEngine.get_user_pid(user) == []
  end

  test "Login User" do
    Server.start_link()
    user = "@bestuser"
    #start a client
    {_, pid} = Client.start_link(user)
    #register the client
    GenServer.call(pid, :register)
    #login the user
    GenServer.call(pid, :login)
    # Use Server backend API to check if user is logged in
    assert TwitterEngine.is_user_logged_in(user) == true
  end

  test "Logout User" do
    Server.start_link()
    user = "@bestuser"
    #start a client
    {_, pid} = Client.start_link(user)
    #register the client
    GenServer.call(pid, :register)
    #login the user
    GenServer.call(pid, :login)
    # Use Server backend API to check if user is logged in
    assert TwitterEngine.is_user_logged_in(user) == true
    #logout the user
    GenServer.call(pid, :logoff)
    # Use Server backend API to check if user is logged out
    assert TwitterEngine.is_user_logged_in(user) == false
  end

  test "Send Tweet" do
    Server.start_link()
    user = "@bestuser"
    #start a client
    {_, pid} = Client.start_link(user)
    #register the client
    GenServer.call(pid, :register)
    #login the user
    GenServer.call(pid, :login)
    #send tweet from user
    tweet = "Hey @elon_musk #tech"
    GenServer.cast(pid, {:tweet, tweet})
    :timer.sleep(500) #wait for some time as tweet is async call
    # Use Server backend API to check if user is successful
    assert TwitterEngine.fetch_user_tweets(user) == [tweet]
  end

  test "Subscribe to User" do
    Server.start_link()
    user1 = "@bestuser"
    user2 = "@elon_musk"
    clients = ClientAPI.register([user1, user2])
    ClientAPI.login(clients)
    {_, user1_pid} = Enum.at(clients,0)
    {_, user2_pid} = Enum.at(clients,1)
    #user 1 subscribes to user 2
    GenServer.call(user1_pid, {:subscribe, [user2]})
    # Use Server backend API to check if subscribe is successful
    assert TwitterEngine.get_my_followers(user2) == [user1]
    assert TwitterEngine.get_users_I_follow(user1) == [user2]
  end

  test "Query Subscribed Tweet" do
    Server.start_link()
    user1 = "@bestuser"
    user2 = "@elon_musk"
    user3 = "@mordor"
    clients = ClientAPI.register([user1, user2, user3])
    ClientAPI.login(clients)
    {_, user1_pid} = Enum.at(clients,0)
    {_, user2_pid} = Enum.at(clients,1)
    {_, user3_pid} = Enum.at(clients,2)
    #user 1 subscribes to user 2 and user 3
    GenServer.call(user1_pid, {:subscribe, [user2, user3]})
    #send tweet from user 2
    tweet1 = "Hey #tech"
    tweet2 = "My Precious. #TheRing"
    GenServer.cast(user2_pid, {:tweet, tweet1})
    GenServer.cast(user3_pid, {:tweet, tweet2})
    :timer.sleep(500) #wait for some time as tweet is async call
    # Query tweets from client
    tweets = GenServer.call(user1_pid, :querySubscribed)
    assert tweets == [{user2, [tweet1]}, {user3, [tweet2]}]
  end

  test "Query Mentions" do
    Server.start_link()
    user1 = "@bestuser"
    user2 = "@elon_musk"
    user3 = "@mordor"
    clients = ClientAPI.register([user1, user2, user3])
    ClientAPI.login(clients)
    {_, user1_pid} = Enum.at(clients,0)
    {_, user2_pid} = Enum.at(clients,1)
    {_, user3_pid} = Enum.at(clients,2)
    #user 1 subscribes to user 2 and user 3
    GenServer.call(user1_pid, {:subscribe, [user2, user3]})
    #send tweet from user 2
    tweet1 = "Hey @bestuser #tech"
    tweet2 = "My Precious. #TheRing"
    GenServer.cast(user2_pid, {:tweet, tweet1})
    GenServer.cast(user3_pid, {:tweet, tweet2})
    :timer.sleep(500) #wait for some time as tweet is async call
    # Query tweets from client
    tweets = GenServer.call(user1_pid, :queryMentions)
    assert tweets == [tweet1]
  end

  test "Query Hashtags" do
    Server.start_link()
    user1 = "@bestuser"
    user2 = "@elon_musk"
    user3 = "@mordor"
    clients = ClientAPI.register([user1, user2, user3])
    ClientAPI.login(clients)
    {_, user1_pid} = Enum.at(clients,0)
    {_, user2_pid} = Enum.at(clients,1)
    {_, user3_pid} = Enum.at(clients,2)
    #user 1 subscribes to user 2 and user 3
    GenServer.call(user1_pid, {:subscribe, [user2, user3]})
    #send tweet from user 2
    tweet1 = "Hey @bestuser #tech"
    tweet2 = "My Precious. #TheRing"
    GenServer.cast(user2_pid, {:tweet, tweet1})
    GenServer.cast(user3_pid, {:tweet, tweet2})
    :timer.sleep(500) #wait for some time as tweet is async call
    # Query tweets from client
    tweets = GenServer.call(user1_pid, {:queryHashtags, "#TheRing"})
    assert tweets == [tweet2]
  end

  test "Retweet" do
    Server.start_link()
    user1 = "@bestuser"
    user2 = "@elon_musk"
    user3 = "@mordor"
    clients = ClientAPI.register([user1, user2, user3])
    ClientAPI.login(clients)
    {_, user1_pid} = Enum.at(clients,0)
    {_, user2_pid} = Enum.at(clients,1)
    {_, user3_pid} = Enum.at(clients,2)
    #user 3 subscribes to user 2
    GenServer.call(user3_pid, {:subscribe, [user2]})
    #send tweet from user 1 mentioning user 2
    tweet1 = "Hey @elon_musk #tech"
    GenServer.cast(user1_pid, {:tweet, tweet1})
    :timer.sleep(500) #wait for some time as tweet is async call
    #fetch mentions of user 2
    [mentioned_tweet] = GenServer.call(user2_pid, :queryMentions)
    # user 2 retweets mentioned tweet, sending information about original tweet author (user1)
    GenServer.cast(user2_pid, {:retweet, user1, mentioned_tweet})
    :timer.sleep(500) #wait for some time as tweet is async call
    # Query tweets from user 3
    [{user2, [retweet]}] = GenServer.call(user3_pid, :querySubscribed)
    assert Utils.is_retweet(retweet) == true
  end

end
