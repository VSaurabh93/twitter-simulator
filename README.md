# TwitterSimulator

# Overview
A client-server application that mirrors the functionality of Twitter. The idea is to simulate a server which can handle requests from thousands of clients. Following are the functionalities that have been implemented:
1. Register and Delete user
2. Login and Logoff user
3. Subscribe to users
4. Send tweets(with mentions and hashtags)to subscribers
5. Clients receive tweets in which they have been mentioned
6. Retweet a tweet 
7. Search tweets with hashtags and mentions
8. Users receive above types of tweets automatically when logged in

# Architecture:
1. The simulator has three components - the clients, server and the engine
2. The clients are multiple independent GenServer processes and represent a user. The server is a single independent process. The engine is essentially a module(not a process) which has functions for performing create, read, update and delete operations on ETS tables. Only server uses the functions of the engine module.
3. The clients send requests to the server in sync as well as async manner. The server handles the requests using different handle_cast/handle_call operations. Based on the request, the server updates the tables and replies back to the client.

# How to run:
For simulations with a randomised distribution of subscribers:

```mix run --no-halt twitter_simulator.exs num_users num_msg```
#### example:
`mix run --no-halt twitter_simulator.exs 1000 10`

For simulations with a [zipf distribution](https://en.wikipedia.org/wiki/Zipf%27s_law) of subscribers:

`mix run --no-halt twitter_simulator.exs num_users num_msg zipf`
#### example:
`mix run --no-halt twitter_simulator.exs 1000 10 zipf`

# Simulation workflow (sequential):
1. The simulator process (see twitter_simulator.ex) starts up the server process first, then it create the clients.
2. Clients are registered with the server and logged in
3. The clients are given subscribers either randomly or using a zipf distribution (distribution can be chosen through command line arguments)
4. After subscribing, each client sends a predetermined number of tweets(num_msg given from the command line). Tweets are sent asynchronously. Simulator waits for 1 sec for tweets to be received.
5. Each client queries tweets in sync. (All types of query request - mentions, hashtags, subscribed tweets are right now done in sync for the sake of test cases. Final implementation would have all query tweets functionality in async)
6. Each client takes random tweets from the queried tweets and retweet them (retweet is async).
7. Each client queries tweets in which they are mentioned(sync right now, will be made async in final implementation.
8. Each client queries tweets with a certain hashtag(sync right now, will be made async in final implementation.
9. logoff users
10. delete users
11. print statistics such as - tweets_made, tweets_received, retweets_made, query_tweets, query_mentions, query_hashtags

## Test cases(18 total):
There are two files with test cases:

### engine_test.exs
This file contains test cases to test the backend and ETS table operations. These tests were created simultaneously while writing the backend functions. They helped remove lots of bugs.
 1. tables initialization test - to check if tables are getting created
 2. Tweet info extraction test - to extract mentions and hashtags from tweets
 3. User Registration test - to check if user has been added in “users” table
 4. login and logoff user - to check whether user is present/absent in “activeUsers” table
 5. write tweet - to check if tweets are saved in the tweets table
 6. subscribe to tweets - to check if subscribers are stored in the table for each user
 7. tweets with mentions - to fetch mentioned tweets from the “mentions” table
 8. tweets with hashtags - to fetch tweets with a certain hashtag from “hashtags” table

### client_test.exs
This file contains test cases to test the client. In these tests, requests are sent from the client and the results are compared with backend functions
 1. Register User - register a client and check backend if the user has been added
 2. Delete User - send request from client to delete user and check backend if user has been deleted
 3. Login User - to check whether client is getting logged in
 4. Logout User - to check whether client has been logged out
 5. Send Tweet - to check if a client tweet has been sent and stored
 6. Subscribe to User - to check if ac client has been subscribed to other users
 7. Query Subscribed Tweet - to check if a query for subscribers’ tweets gives the correct results.
 8. Query Mentions - to check if a query for current user’s mentions gives the correct results.
 9. Query Hashtags - to check if a client querying for a specific hashtag gives the correct results.
 10. Retweet - to check retweets by the client has the necessary retweet info
