+++
title = 'Nix Functions To Setup Newsboat Urls'
date = 2024-10-22T13:18:36+05:30
draft = false
description = ""
tags = ['all']
+++

RSS is a powerful way to stay updated with your favorite blogs, social media channels, and other online content without being distracted by endless scrolling on the actual platforms. [Newsboat](https://newsboat.org/), a terminal-based RSS reader, is an excellent tool for this.

In this post, I'll guide you through how to set up your newsboat configuration using Nix functions to generate RSS feeds from platforms like YouTube, Twitter, Reddit, Instagram, and Spotify with less boilerplates. For more informations on supported platforms visit [rsshub](https://rsshub.netlify.app/).

### Table of Contents

1. What is Newsboat
3. Setting Up Nix Functions for RSS Feeds
4. Breakdown of Nix Functions for RSS Feeds
5. Configuring Newsboat with Nix
6. Conclusion

# Setting Up Nix Functions for RSS Feeds

In Nix, you can use functions to generate your RSS feed URLs dynamically. Here's an example block of Nix functions for various platforms:

```nix
{ ... }:
let
  # Function to generate Instagram RSS feed URLs
  instagramFeeds = users: map (userNames: {
    tags = [ "instagram" ];
    url = "https://rsshub.app/picuki/profile/${userNames}";
  }) users;

  # Function to generate Twitter RSS feed URLs using Nitter
  twitterFeeds = users: map (userNames: {
    tags = [ "twitter" ];
    url = "https://nitter.privacydev.net/${userNames}/rss";
  }) users;

  # Function to generate Reddit RSS feed URLs
  redditFeeds = users: map (userNames: {
    tags = [ "reddit" ];
    url = "https://www.reddit.com/r/${userNames}.rss";
  }) users;

  # Function to generate YouTube RSS feed URLs using the channel username
  youTubeFeeds = users: map (userNames: {
    tags = [ "youtube" ];
    url = "https://rsshub.app/youtube/user/@${userNames}";
  }) users;
in
  {
    # Rest of the configuration...
  }
```

# Breakdown of the Nix Functions

In Nix, functions are written as:

#### Single parameter

```nix
param1: {
    # Function Body
}
```
#### Two parameters

```nix
param1: param2: {
    # Function Body
}
```

param1, param2 are inputs (arguments) to the function. That means we can write a function and pass just the username or unique id then the function we take care of the boilerplates parts of the links.

#### Example

If the input list is 
```nix
instagramFeeds = [ "kartikaaryan" "shraddhakapoor" ]
```

the output will be:

```nix
[
  { tags = [ "instagram" ]; url = "https://rsshub.app/picuki/profile/kartikaaryan"; }
  { tags = [ "instagram" ]; url = "https://rsshub.app/picuki/profile/shraddhakapoor"; }
]
```

Let's create a funtions for YouTube feeds

```nix
{ ... }:
let
Youtube = userName: tags: {
    tags = tags;
    url = "https://rsshub.app/youtube/user/@${userName}";
  };
in
{
}
```

# Putting all togethere

```nix
{ ... }:
let
Youtube = userName: tags: {
    tags = tags;
    url = "https://rsshub.app/youtube/user/@${userName}";
  };
in
{
programs.newsboat = {
    enable = true;
    browser = "firefox";
    autoReload = false;
    urls = [
      {tags = [ "articles" ]; url = "https://feeds.feedburner.com/collabfund";}

      (Youtube "JFlaMusic" [ "youtube" "music" ])
      (Youtube "cmanishanthreghunath" [ "academics" ])
      (Youtube "AccountingStuff" [ "academics" ])
      (Youtube "CinemaStellar" [ "youtube" "movies" ])
      (Youtube "DanMurrellMovies" [ "youtube" "movies" ])
      ];
}
```



1. Instagram RSS Feeds

```nix
instagramFeeds = users: map (userNames: {
  tags = [ "instagram" ];
  url = "https://rsshub.app/picuki/profile/${userNames}";
}) users;
```

Purpose: This function generates RSS feed URLs for Instagram profiles.
Input: A list of Instagram usernames (users).
Working: The function applies a mapping (map) over the list of usernames. For each username, it returns an RSS feed URL along with the tag "instagram".
Example: For the username kartikaaryan, the URL generated would be:

    nix

    https://rsshub.app/picuki/profile/kartikaaryan

3. Reddit RSS Feeds

nix

redditFeeds = users: map (userNames: {
  tags = [ "reddit" ];
  url = "https://www.reddit.com/r/${userNames}.rss";
}) users;

    Purpose: Generates RSS feed URLs for Reddit subreddits.
    Example: For the subreddit rust, the URL generated is:

    nix

    https://www.reddit.com/r/rust.rss

4. YouTube RSS Feeds

nix

youTubeFeeds = users: map (userNames: {
  tags = [ "youtube" ];
  url = "https://rsshub.app/youtube/user/@${userNames}";
}) users;

    Purpose: Generates RSS feed URLs for YouTube channels based on their usernames.
    Example: For the username letsgetrusty, the URL generated is:

    nix

    https://rsshub.app/youtube/user/@letsgetrusty

Configuring Newsboat with Nix

Once you have these functions defined, you can integrate them into your Newsboat configuration like this:

nix

{
  programs.newsboat = {
    enable = true;
    browser = "linkhandler";
    autoReload = false;
    reloadTime = 60;
    reloadThreads = 10;

    urls = [
      # Static RSS Feeds
      { tags = [ "articles" ]; url = "https://jamesclear.com/feed"; }
      { tags = [ "articles" ]; url = "http://calnewport.com/feed"; }

      # Dynamic Feeds from Functions
      # YouTube channels
      (Youtube "JFlaMusic" [ "youtube", "music" ])
      (Youtube "TechnoTim" [ "youtube", "tech" ])

      # Add more feeds from other platforms using the functions
    ]
    ++ instagramFeeds [
      "kartikaaryan"
      "shraddhakapoor"
    ]
    ++ twitterFeeds [
      "elonmusk"
      "naval"
    ]
    ++ redditFeeds [
      "rust"
      "nixos"
    ];
  };
}

How This Works:

    Static Feeds: You can manually define static RSS feeds like blogs or podcasts.
    Dynamic Feeds: For Instagram, Twitter, Reddit, and YouTube, you use the functions (instagramFeeds, twitterFeeds, etc.) to dynamically generate the RSS feed URLs. These functions take lists of usernames or subreddit names and return the corresponding URLs.

The output of the urls key in Newsboat will contain a mixture of static feeds and dynamically generated feeds, ensuring you get the latest content from your chosen platforms.
Conclusion

By using Nix to manage your Newsboat configuration, you gain flexibility and scalability. Instead of manually adding new feeds, you can automate the process using Nix functions to generate feeds dynamically for various platforms. This method reduces redundancy, keeps your configuration clean, and makes it easier to maintain over time.

Using RSS feeds through Newsboat combined with the power of Nix, you can efficiently manage your online content consumption while maintaining control over the platforms you engage with.

Next Steps:

    Experiment with adding more platforms to your Nix configuration.
    Add custom macros or keybindings to further enhance your Newsboat experience.
    Share your configuration and improvements with the community!






# Preview
```nix { .my_codeblock hl_Lines="0"}
{ ... }:
let
Youtube = userName: tags: {
  tags = tags;
  url = "https://rsshub.app/youtube/user/@${userName}";
};
youTubeFeeds = users: map ( userNames: {
    tags = [ "youtube" ];
    url = "https://rsshub.app/youtube/user/@${userNames}";
    }) users;
in
{
  programs.newsboat = {
    enable = true;
    browser = "firefox";
    autoReload = false;
    urls = [
    {tags = [ "articles" ]; url = "https://feeds.feedburner.com/collabfund";}
    {tags = [ "articles" ]; url = "https://markmanson.net/feed";}
    {tags = [ "articles" ]; url = "https://proton.me/blog/feed";}

    (Youtube "CinemaStellar" [ "youtube" "movies" ]) 
      (Youtube "DanMurrellMovies" [ "youtube" "movies" ])
    ]
    ++ youTubeFeeds [
    "jonhoo"
      "LukeSmithxyz"
      "NoBoilerplate"
      "letsgetrusty"
      "ThePrimeagen"
      "mkbhd"
      "bugswriter_"
      "DistroTube"
      "shal.e8033"
      "Emergent_Mind"
    ];

    extraConfig = ''
      bind-key j down
      bind-key k up
      bind-key j next articlelist
      bind-key k prev articlelist
      '';
  };
}
```
# Home-manager Option
### programs.newsboat.urls 

List of news feeds. Leave it empty if you want to manage feeds imperatively, for example, using Syncthing.

#### Declarations

Type : list of (submodule)

Default :
```nix
programs.newsboat.url = [ ];
```

Example :
```nix 
programs.newsboat.url = [
{ tags = [ "foo" "bar" ]; url = "http://example.com"; }
];
```

Let's go through how each function works step by step in the let block:

# 1. General Overview of Function Structure in Nix

In Nix, functions are written as:

```nix
param1: param2: {
    # Function Body
}
```

param1, param2 are inputs (arguments) to the function. That means we can write a function and pass just the username or unique id then the function we take care of the boilerplates parts of the link.

ie,
```nix
programs.newsboat.url = [
  { tags = [ "twitter" ]; url = "https://nitter.privacydev.net/elonmusk/rss"; } # we will make a funtion and pass only the username.
  { tags = [ "twitter" ]; url = "https://nitter.privacydev.net/jonhoo/rss"; }
]
```


The function body returns a value, typically a Nix set (record), which consists of key-value pairs like tags and url.

The functions here are defined in a way that they take parameters (e.g., userNames for Instagram, channel_id for YouTube) and output a record containing:

Tags: A list of categories like "instagram", "youtube", etc.
URL: The actual RSS feed URL generated based on the provided parameters.

Now, let's break down the core mechanics:

2. Function instagramFeeds

nix

instagramFeeds = users: map (userNames: {
    tags = [ "instagram" ];
    url = "https://rsshub.app/picuki/profile/${userNames}";
    }) users;

Purpose: This function generates Instagram RSS feed URLs for a list of users.

Parameters:
users: A list of Instagram usernames is passed into the function.

How it works:
The function takes a list of Instagram usernames (users).
It uses the map function to iterate over each userNames in the list.
map applies a given function to every element in the list and returns a new list.
For each username, the map function generates a record containing:
tags: A list with the single tag "instagram".
url: The URL for the user's Instagram feed using the RSSHub endpoint.
The url field dynamically injects the userNames into the URL string:

nix

"https://rsshub.app/picuki/profile/${userNames}"



# Final code
```nix { .my_codeblock hl_Lines="0"}
{ ... }:
let
instagramFeeds = users: map ( userNames: {
    tags = [ "instagram" ];
    url = "https://rsshub.app/picuki/profile/${userNames}";
    }) users;
twitterFeeds = users: map ( userNames: {
    tags = [ "twitter" ];
    url = "https://nitter.privacydev.net/${userNames}/rss";
    }) users;
redditFeeds = users: map ( userNames: {
    tags = [ "reddit" ];
    url = "https://www.reddit.com/r/${userNames}.rss";
    }) users;
youTubeFeeds = users: map ( userNames: {
    tags = [ "youtube" ];
    url = "https://rsshub.app/youtube/user/@${userNames}";
    }) users;
Youtube = userName: tags: {
  tags = tags;
  url = "https://rsshub.app/youtube/user/@${userName}";
};
YoutubeId = channel_id: tags: {
  tags = tags;
  url = "https://www.youtube.com/feeds/videos.xml?channel_id=${channel_id}";
};
YtMusicChart = category: countryCode: tags: {
  tags = tags;
  url = "https://rsshub.app/youtube/charts/${category}/${countryCode}/RightNow";
};
Spotify = category: name: id: {
  tags = [ "music" ];
  url = "https://rsshub.app/spotify/${category}/${id}";
};
in 
{
  programs.newsboat = {
    enable = true;
    browser = "linkhandler";
    autoReload = false;
    urls = [
      {tags = [ "articles" ]; url = "https://feeds.feedburner.com/collabfund";}
      (Youtube "CinemaStellar" [ "youtube" "movies" ])
      (Youtube "DanMurrellMovies" [ "youtube" "movies" ])
      (YoutubeId "UC7YOGHUfC1Tb6E4pudI9STA" [])
      (YoutubeId "UCP7WmQ_U4GB3K51Od9QvM0w" [])
      (YtMusicChart "TopSongs" "in" [ "YtMusic" ])
      (Spotify "playlist" "Top Songs - Global" "37i9dQZEVXbNG2KDcFcKOF")
      (Spotify "playlist" "Top Songs - India" "37i9dQZEVXbMWDif5SCBJq")
      (Spotify "artist" "Halsey"            "26VFTg2z8YR0cCuwLzESi2")
      (Spotify "artist" "The Chainsmokers"  "69GGBxA162lTqCwzJG5jLp")
      ]
      ++ youTubeFeeds [
        "jonhoo"
        "LukeSmithxyz"
        "NoBoilerplate"
        ]
        ++ twitterFeeds [
          "jonhoo"
          "MikaPikaZo"
        ]
        ++ redditFeeds [
          "rust"
          "nixos"
          "unixporn"
        ]
        ++ instagramFeeds [
          "kartikaaryan"
          "shraddhakapoor"
        ];

    extraConfig = ''
      bind-key j down
      bind-key k up
      '';
  };
}
```

