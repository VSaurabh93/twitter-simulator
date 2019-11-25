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

  def init(state) do
    TwitterEngine.initialize_tables()
    IO.puts("tables initialized")
    {:ok, state}
  end

end
