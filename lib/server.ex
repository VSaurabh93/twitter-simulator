defmodule Server do
use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :server)
  end

  def handle_call({:register_user, user, client_pid}, _from, state) do
    TwitterEngine.register_user(user, client_pid)
    {:reply, :registered, state}
  end

  def handle_call({:login_user, user}, _from, state) do
    TwitterEngine.login_user(user)
    {:reply, :loggedIn, state}
  end

  def handle_call({:subscribe, user, users_to_subscribe}, _from, state) do
    users_subscribed = TwitterEngine.subscribe_to_users(user, users_to_subscribe)
    {:reply, {:subscribed, users_subscribed}, state}
  end

  def handle_cast({:tweet, {user_id, tweet_text}}, state) do
    TwitterEngine.write_tweet(user_id, tweet_text)
    TwitterEngine.get_my_followers(user_id) |> Enum.each(fn follower ->
      client_pid = TwitterEngine.get_user_pid(follower)
      GenServer.cast(client_pid, {:receiveTweet, user_id, tweet_text})
    end)
    {:noreply, state}
  end


  def init(state) do
    TwitterEngine.initialize_tables()
    IO.puts("tables initialized")
    {:ok, state}
  end

end
