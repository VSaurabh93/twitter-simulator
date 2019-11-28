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
    CounterService.update_counter(:incrementTweetCount)
    {:noreply, user_id}
  end

  def handle_cast({:retweet, original_author, tweet_text}, user_id) do
    IO.puts("inside retweet")
    tweet_text =
    if Utils.is_retweet(tweet_text) == false, do: Utils.prepare_retweet(original_author, tweet_text), else: tweet_text
    GenServer.cast(:server, {:tweet, {user_id, tweet_text}})
    CounterService.update_counter(:incrementRetweetCount)
    {:noreply, user_id}
  end

  def handle_cast({:receiveTweet, from_user, tweet_text}, user_id) do
    IO.puts(user_id <> "> received tweet from " <> from_user <> " \"" <> tweet_text <> "\"")
    CounterService.update_counter(:incrementReceivedTweetsCount)
    {:noreply, user_id}
  end

  def handle_cast({:receiveMention, from_user, tweet_text}, user_id) do
    IO.puts(user_id <> "> received mention from " <> from_user <> " \"" <> tweet_text <> "\"")
    {:noreply, user_id}
  end

  def handle_cast({:receiveQueryResults, resultsType, results}, user_id) do
      IO.puts(user_id <> "> received results :" <>
      "#{resultsType}" <> "->\n" <> "#{results}" <> "\n")

      cond do
        resultsType == :querySubscribed -> CounterService.update_counter(:incrementQueryTweetsCount)
        resultsType == :queryHashtags -> CounterService.update_counter(:incrementQueryHashtagsCount)
        resultsType == :queryMentions -> CounterService.update_counter(:incrementQueryMentionsCount)
        true -> true
      end
      {:noreply, user_id}
  end

  # def handle_cast({:querySubscribed}, user_id) do
  #   GenServer.cast(:server, {:querySubscribed, user_id})
  #   {:noreply, user_id}
  # end

  # def handle_cast({:queryHashtags, hashtag}, user_id) do
  #   GenServer.cast(:server, {:queryHashtags, hashtag, user_id})
  #   {:noreply, user_id}
  # end

  # def handle_cast({:queryMentions}, user_id) do
  #   GenServer.cast(:server, {:queryMentions, user_id})
  #   {:noreply, user_id}
  # end

  def handle_call(:querySubscribed, _from, user_id) do
    tweets = GenServer.call(:server, {:querySubscribed, user_id})
    #IO.inspect(["query subscribed: ", tweets])
    CounterService.update_counter(:incrementQueryTweetsCount)
    IO.puts("Querying subscribed tweets of #{user_id}:\n" <>
            Utils.query_subscribed_tweets_prettify(tweets))
    {:reply, tweets, user_id}
  end

  def handle_call({:queryHashtags, hashtag}, _from, user_id) do
    tweets = GenServer.call(:server, {:queryHashtags, hashtag, user_id})
    #IO.inspect(["query hashtag " <> hashtag <> " : ", tweets])
    CounterService.update_counter(:incrementQueryHashtagsCount)
    IO.puts("#{user_id} querying hashtag #{hashtag}:\n" <>
            Utils.query_hashtags_prettify(tweets))
    {:reply, tweets, user_id}
  end

  def handle_call(:queryMentions, _from, user_id) do
    tweets = GenServer.call(:server, {:queryMentions, user_id})
    CounterService.update_counter(:incrementQueryMentionsCount)
    #IO.inspect(["query mentions of " <> user_id <> " : ", tweets])
    IO.puts("Querying mentions of #{user_id}:\n" <>
            Utils.query_mentions_prettify(tweets))
    {:reply, tweets, user_id}
  end

end

