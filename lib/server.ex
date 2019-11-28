defmodule Server do
use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :server)
  end

  def handle_call({:register_user, user, client_pid}, _from, state) do
    TwitterEngine.register_user(user, client_pid)
    {:reply, :registered, state}
  end

  def handle_call({:delete_user, user}, _from, state) do
    TwitterEngine.delete_user(user)
    {:reply, :deleted, state}
  end

  def handle_call({:login_user, user}, _from, state) do
    TwitterEngine.login_user(user)
    {:reply, :loggedIn, state}
  end

  def handle_call({:logoff_user, user}, _from, state) do
    TwitterEngine.login_user(user)
    {:reply, :loggedOut, state}
  end

  def handle_call({:subscribe, user, users_to_subscribe}, _from, state) do
    users_subscribed = TwitterEngine.subscribe_to_users(user, users_to_subscribe)
    {:reply, {:subscribed, users_subscribed}, state}
  end

  def handle_cast({:tweet, {user_id, tweet_text}}, state) do
    TwitterEngine.write_tweet(user_id, tweet_text)

    # tweet to followers
    TwitterEngine.get_my_followers(user_id) |> Enum.each(fn follower ->
      client_pid = TwitterEngine.get_user_pid(follower)
      if TwitterEngine.is_user_logged_in(follower) == true do
        GenServer.cast(client_pid, {:receiveTweet, user_id, tweet_text})
      end
    end)

    # tweet to mentioned users
    {_tweet, mentions, _hashtags} = Utils.extract_tweet_info(tweet_text)
    Enum.each(mentions, fn mentioned_user ->
      client_pid = TwitterEngine.get_user_pid(mentioned_user)
      if TwitterEngine.is_user_logged_in(mentioned_user) == true do
        GenServer.cast(client_pid, {:receiveMention, user_id, tweet_text})
      end
    end)

    {:noreply, state}
  end

  def handle_cast({:querySubscribed, user}, state) do
    following = TwitterEngine.get_users_I_follow(user)
    tweets = Enum.map(following, fn followed_user ->
      {followed_user, TwitterEngine.fetch_user_tweets(followed_user)}
    end)
    client_pid = TwitterEngine.get_user_pid(user)
    GenServer.cast(client_pid, {:receiveQueryResults, :querySubscribed, tweets})
    {:noreply, state}
  end

  def handle_cast({:queryHashtags, hashtag, user}, state) do
    tweets = TwitterEngine.fetch_tweets_with_hashtag(hashtag)
    client_pid = TwitterEngine.get_user_pid(user)
    GenServer.cast(client_pid, {:receiveQueryResults, :queryHashtags, {hashtag, tweets}})
    {:noreply, state}
  end

  def handle_cast({:queryMentions, user}, state) do
    tweets = TwitterEngine.fetch_tweets_with_mentions(user)
    client_pid = TwitterEngine.get_user_pid(user)
    GenServer.cast(client_pid, {:receiveQueryResults, :queryMentions, tweets})
    {:noreply, state}
  end


  def init(state) do
    TwitterEngine.initialize_tables()
    IO.puts("tables initialized")
    {:ok, state}
  end

end
