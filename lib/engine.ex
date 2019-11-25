defmodule TwitterEngine do

  def initialize_tables() do
    :ets.new(:users, [:set, :public, :named_table])
    :ets.new(:followers, [:set, :public, :named_table])
    :ets.new(:tweets, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:hashtags, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:mentions, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    :ets.new(:following, [:set, :public, :named_table])
    :ets.new(:activeUsers, [:set, :public, :named_table])
  end

  def register_user(user, pid) do
    #inserts only once. returns false on failed insert
    :ets.insert_new(:users,{user, pid})
  end

  def delete_user(user) do
    :ets.delete(:users, user)
  end

  def subscribe_to_users(user, users_to_subscribe) do
    users_to_subscribe =
      Enum.filter(users_to_subscribe, fn sub -> :ets.member(:users, sub) end)
    append_items_by_key_in_table(:following, user, users_to_subscribe)

    Enum.each(users_to_subscribe, fn user_to_subscribe ->
      append_items_by_key_in_table(:followers, user_to_subscribe, [user]) end)
  end


  defp append_items_by_key_in_table(table, key, values) do
    new_values = cond do
      :ets.member(table, key) ->
        [{_, prev_values}] = :ets.lookup(table, key)
        prev_values ++ values
      true -> values
    end
    :ets.insert(table,{key, new_values})
  end

  def write_tweet(user, tweet)  do

    if get_user_pid(user) == [] , do: IO.puts(user <> " doesn't exist. Can't write tweet.")

    {_, mentions, hashtags} = Utils.extract_tweet_info(tweet)

      # insert into tweet table by tweet id
      append_items_by_key_in_table(:tweets, user, [tweet])

      # insert into mentions table
      Enum.each(mentions, fn mentioned_user ->
        append_items_by_key_in_table(:mentions, mentioned_user, [tweet])
      end)

      #insert into hashtags table
      Enum.each(hashtags, fn hashtag ->
       append_items_by_key_in_table(:hashtags, hashtag, [tweet])
      end)
  end

  def retweet() do
      #TODO retweets
  end

  def fetch_user_tweets(user) do
    result = :ets.lookup(:tweets, user)
    if result == [] do
      result
    else
      [{_, tweets}] = result
      tweets
    end
  end

  def fetch_tweets_with_hashtag(hashtag) do
    result = :ets.lookup(:hashtags, hashtag)
    if result == [] do
      result
    else
      [{_user, tweets_with_hashtags}] = result
      tweets_with_hashtags
    end
  end

  def fetch_tweets_with_mentions(user) do
    result = :ets.lookup(:mentions, user)
    if result == [] do
      result
    else
      [{_user, tweets_with_mentions}] = result
      tweets_with_mentions
    end
  end

  def get_users_I_follow(user) do
    result = :ets.lookup(:following, user)
    if result == [] do
      result
    else
      [{_user, following}] = result
      following
    end
  end

  def get_user_pid(user) do
    result = :ets.lookup(:users, user)
    if result == [] do
      result
    else
      [{_user, pid}] = result
      pid
    end
  end

  def is_user_logged_in(user) do
    :ets.member(:activeUsers, user)
  end

  def login_user(user) do
    if :ets.member(:users, user) do
      :ets.insert(:activeUsers, {user})
    else
      False
    end
  end

  def logoff_user(user) do
    :ets.delete(:activeUsers, user)
  end

end
