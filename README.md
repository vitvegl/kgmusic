# KgMusic

This gem find music albums on kibergrad.fm

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kgmusic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kgmusic

## Usage
    require 'kgmusic'

    Using Client API:

      cli = KgMusic::Client.new

      popular_artists = cli.popular_artists

      popular_genres = cli.popular_genres

      all_genres = cli.all_genres

    Using Artists API:

      artists = KgMusic::Artists.show_info(146)

    Using Downloader:

      music = KgMusic::Downloader.new :artist => 'God Is An Astronaut', :album => 'God Is An Astronaut'

      result = music.search # find album

      album = music.download_album # download album
