defmodule Utils do
  def extract_tweet_info(tweet) do
    mentions = Regex.scan(~r/@[a-z0-9A-Z_]*/, tweet) |> List.flatten
    hashtags = Regex.scan(~r/\#[a-z0-9A-Z_]*/,tweet) |> List.flatten
    {tweet, mentions, hashtags}
  end

  def generate_tweet_id() do
    "no_id"
  end

  @tweet_text_pool  [
    "Hey", "This is COP5615", "This is a simulated tweet",
    "A long time ago in a galaxy far, far away..",
    "God doesn't exist", "The aliens are coming", "ROTFL",
    "Take the red pill", "Better be Gryffindor", "Focus",
    "Still working on the DOS assignment", "This is fun",
    "Windows has stopped responding", "This tweet took a really long time to type",
    "Keep calm and meditate", "The seven wonders of the world", "Arise. March. Conquer.",
    "The good things in life", "The dog ate my HW pendrive", "I pronounce thee a graduate student",
    "The tweets.. Make them stop.", "Sometimes I feel like I am stuck in a simulation", "LOL. This IS a simulation",
    "May the force be with you", "Valar Moghulis", "Hodor", "I am Groot."
  ]

  @hashtags_pool [
    "#yoga", "#technology", "#science", "#space",
    "#innovation", "#design", "#ai", "#tech",
    "#cloud", "#bigdata", "#innovation", "#ios",
    "#iot", "#technews", "#device", "#engineering",
    "#crypto", "#funny", "#photography", "#friday",
    "#crowdfunding", "#cryptocurrency", "#tbt", "#goals"
  ]

  def generate_random_tweet(user_pool) do

    tweet_text = Enum.take_random(@tweet_text_pool, 1)
    hashtags = Enum.take(@hashtags_pool, 3) |> Enum.take_random(1)
    mentions = Enum.take_random(user_pool, 2)
    tweet = tweet_text ++  mentions ++ hashtags
    Enum.reduce(tweet, fn(x, acc) -> acc <> " " <> x end)
  end
end
