defmodule Client do
  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, {user_id})
  end

  def init({user_id}) do
    {:ok, user_id}
  end

  def handle_call(:register, _from, user_id) do
    reply = GenServer.call(:server, {:register_user, user_id, self()})
    IO.inspect("Registered user " <> user_id)
    {:reply, reply, user_id}
  end

  def handle_call(:delete_user, _from, user_id) do
    reply = GenServer.call(:server, {:delete_user, user_id})
    IO.inspect("Deleted user " <> user_id)
    {:reply, reply, user_id}
  end

  def handle_call(:login, _from, user_id) do
    reply = GenServer.call(:server, {:login_user, user_id})
    IO.inspect("logged in user " <> user_id)
    {:reply, reply, user_id}
  end

  def handle_call(:logoff, _from, user_id) do
    reply = GenServer.call(:server, {:logoff_user, user_id})
    IO.inspect("logged out user " <> user_id)
    {:reply, reply, user_id}
  end

  def handle_call({:subscribe, users_to_subscribe}, _from, user_id) do
    {:subscribed, users_subscribed} = GenServer.call(:server, {:subscribe, user_id, users_to_subscribe})
    IO.inspect([user_id <> " subscribed to users "] ++ users_subscribed)
    {:reply, users_subscribed, user_id}
  end

  def handle_cast({:tweet, tweet_text}, user_id) do
    GenServer.cast(:server, {:tweet, {user_id, tweet_text}})
    {:noreply, user_id}
  end

  def handle_cast({:receiveTweet, from_user, tweet_text}, user_id) do
    IO.puts(user_id <> " received from " <> from_user <> " \"" <> tweet_text <> "\"")
    {:noreply, user_id}
  end

end

