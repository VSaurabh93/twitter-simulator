defmodule CounterService do
use GenServer

  def start_link() do

    tweets_made=0
    tweets_received =0
    retweets_made=0
    query_tweets=0
    query_mentions=0
    query_hashtags=0

    counter = {
      tweets_made,
      tweets_received,
      retweets_made,
      query_tweets,
      query_mentions,
      query_hashtags
    }

    GenServer.start_link(__MODULE__, counter, name: :counter)

  end

  def handle_cast(:incrementTweetCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made+1, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags} }
  end

  def handle_cast(:incrementReceivedTweetsCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made, tweets_received+1, retweets_made, query_tweets, query_mentions, query_hashtags} }
  end

  def handle_cast(:incrementRetweetCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made, tweets_received, retweets_made+1, query_tweets, query_mentions, query_hashtags} }
  end

  def handle_cast(:incrementQueryTweetsCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made, tweets_received, retweets_made, query_tweets+1, query_mentions, query_hashtags} }
  end

  def handle_cast(:incrementQueryMentionsCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made, tweets_received, retweets_made, query_tweets, query_mentions+1, query_hashtags} }
  end

  def handle_cast(:incrementQueryHashtagsCount, {tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags}) do
    {:noreply,{tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags+1} }
  end

  def get_statistics() do
    count = GenServer.call(:counter, :getStats)
    {
      tweets_made,
      tweets_received,
      retweets_made,
      query_tweets,
      query_mentions,
      query_hashtags
    } = count
    IO.puts("tweets_made: #{tweets_made}\ntweets_received: #{tweets_received}\nretweets_made: #{retweets_made}\nquery_tweets: #{query_tweets}\nquery_mentions: #{query_mentions}\nquery_hashtags: #{query_hashtags}\n")
  end

  def handle_call(:getStats, _from, counter) do
    {:reply, counter, counter}
  end

  def update_counter(type) do
    GenServer.cast(:counter, type)
  end

  def init(state) do
    {:ok, state}
  end

end
