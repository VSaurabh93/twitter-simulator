defmodule EngineTest do
  use ExUnit.Case
  doctest TwitterEngine

  test "tables initialization test" do
    TwitterEngine.initialize_tables()

    assert :ets.whereis(:users) != :undefined
    assert :ets.whereis(:followers) != :undefined
    assert :ets.whereis(:tweets) != :undefined
    assert :ets.whereis(:hashtags) != :undefined
    assert :ets.whereis(:mentions) != :undefined
    assert :ets.whereis(:following) != :undefined
    assert :ets.whereis(:activeUsers) != :undefined
  end

  test "Tweet info extraction test" do
    tweet = "hey @bestuser @VSaurabh93 @TheTweetofGod #COP5615isgreat @elon_musk #FortyTwo"
    {_, mentions, hashtags} = Utils.extract_tweet_info(tweet)
    assert mentions == ["@bestuser", "@VSaurabh93", "@TheTweetofGod", "@elon_musk"]
    assert hashtags == ["#COP5615isgreat", "#FortyTwo"]
  end

  test "User Registration test" do
    TwitterEngine.initialize_tables()
    user = "@bestuser"
    TwitterEngine.register_user(user, self())
    assert TwitterEngine.get_user_pid(user) == self()
  end

  defp init(user) do
    TwitterEngine.initialize_tables()
    TwitterEngine.register_user(user, self())
    TwitterEngine.login_user(user)
  end

  test "login and logoff user" do
    user = "@bestuser"
    init(user)
    assert TwitterEngine.is_user_logged_in(user) == true
    TwitterEngine.logoff_user(user)
    assert TwitterEngine.is_user_logged_in(user) == false
  end

  test "write tweet" do
    user = "@bestuser"
    init(user)
    tweet1 = "hey @bestuser @VSaurabh93 @TheTweetofGod #COP5615isgreat @elon_musk #FortyTwo"
    tweet2 = "Keep calm and code. @bestuser #COP5615isgreat #Project"
    TwitterEngine.write_tweet(user, tweet1)
    TwitterEngine.write_tweet(user, tweet2)
    assert TwitterEngine.fetch_user_tweets(user) == [tweet1, tweet2]
  end

  test "subscribe to tweets" do
    user = "@bestuser"
    init(user)
    following = ["@elonmusk", "@TheTweetofGod"]
    TwitterEngine.register_user("@elonmusk", self())
    TwitterEngine.register_user("@TheTweetofGod", self())
    TwitterEngine.subscribe_to_users(user, following)
    assert TwitterEngine.get_users_I_follow(user) == following
  end

  test "tweets with mentions" do
    user = "@bestuser"
    init(user)
    TwitterEngine.register_user("@elonmusk", self())
    TwitterEngine.register_user("@TheTweetofGod", self())
    following = ["@elonmusk", "@TheTweetofGod"]
    TwitterEngine.subscribe_to_users(user, following)
    godTweet1 = "I don’t exist. What’s your excuse? #FortyTwo @bestuser"
    godTweet2 = "If you pray hard enough, nothing happens. #TrustMe"
    TwitterEngine.write_tweet("@TheTweetofGod", godTweet1)
    TwitterEngine.write_tweet("@TheTweetofGod", godTweet2)
    elonTweet = "And, no, I'm not an alien...but I used to be one @TheTweetofGod @bestuser"
    TwitterEngine.write_tweet("@elonmusk", elonTweet)

    tweets = TwitterEngine.fetch_tweets_with_mentions(user)
    assert  tweets == [godTweet1, elonTweet]

  end

  test "tweets with hashtags" do
    user = "@bestuser"
    init(user)
    TwitterEngine.register_user("@elonmusk", self())
    TwitterEngine.register_user("@TheTweetofGod", self())
    godTweet = "I don’t exist. What’s your excuse? #FortyTwo #COP5615isgreat @bestuser"
    elonTweet = "It shall be called The Boring Company #COP5615isgreat"
    TwitterEngine.write_tweet("@TheTweetofGod", godTweet)
    TwitterEngine.write_tweet("@elonmusk", elonTweet)
    assert TwitterEngine.fetch_tweets_with_hashtag("#COP5615isgreat") == [godTweet, elonTweet]

  end

end
