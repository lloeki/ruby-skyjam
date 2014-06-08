# ruby-skyjam

Deftly interact with Google Music (a.k.a Skyjam)

## Important foreword

This uses the same *device id* as *Google's Music Manager* (your MAC address).
The reason is that incrementing the MAC is not a globally solving solution
and that you most probably won't need Google's Music Manager afterwards
because it's, well, “lacking” (to say the least). This may apply to the
*Chrome extension* too but I'm not sure so you'd be best not using it (it's
similarly lacking anyway).

## On the command line

```bash
gem install skyjam     # install the gem
skyjam --auth          # authenticates with OAuth, do it only once
skyjam ~/Music/Skyjam  # download files into the specified directory
```

Existing files will not be overwritten, so that makes
a nice sync/resume solution. Tracks are downloaded atomically, so
you're safe to `^C`.

## Inside ruby

Add 'skyjam' to your `Gemfile` (you *do* use Gemfiles?)

Here's a sample of what you can do now:

```ruby
require 'skyjam'

# where you want to store your library
path = File.join(ENV['HOME'], 'Music/Skyjam')

# Interactive authentication, only needed once.
# This performs OAuth and registers the device
# into Google Music services. Tokens are persisted
# in ~/.config/skyjam
Skyjam::Library.auth

# Connect the library to Google Music services
# This performs an OAuth refresh with persisted
# tokens
lib = Skyjam::Library.connect(path)

puts lib.tracks.count

lib.tracks.take(5).each { |t| puts t.title }  # metadata is exposed as accessors

track = lib.tracks.first
track.download               # atomically download track into the library
track.download               # noop, since now the file exists
track.download(lazy: false)  # forces the download

track.data                # returns track audio data from the file (since it's downloaded)
track.data(remote: true)  # forces remote data fetching
```

The following snippet also makes for an interesting interactive
REPL to interact with Google Music, wich is a testament to the
clarity aimed at in this project:

```ruby
require 'skyjam'
require 'pry'
Skyjam::Library.connect('some/where').pry
```

## Future features

Yes, trouble free upload for the quality minded is coming.

Also, see [TODO](TODO.md).

## Goals

Have a potent tool that doubles as a library and a documentation
of the Google Music API (including ProtoBuf definitions)

## References

* [Simon Weber's Unofficial Google Music API](https://github.com/simon-weber/Unofficial-Google-Music-API/)
* [Google Music protocol reverse engineering effort](http://www.verious.com/code/antimatter15/google-music-protocol/) (disappeared)
