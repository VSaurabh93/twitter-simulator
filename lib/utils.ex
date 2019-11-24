defmodule Utils do
  def extract_tweet_info(tweet) do
    mentions = Regex.scan(~r/@[a-z0-9A-Z_]*/, tweet) |> List.flatten
    hashtags = Regex.scan(~r/\#[a-z0-9A-Z_]*/,tweet) |> List.flatten
    {tweet, mentions, hashtags}
  end

  def generate_tweet_id() do
    "no_id"
  end
end
