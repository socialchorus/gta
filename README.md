# GTA - the Git Transit Authority

GTA is a git-based deploy tool for moving code from stage to stage.

Heroku has made git deploys an awesome standard. Mislav's git-deploy gem
has made this ease of deploy a possibility for servers that are not
Heroku too. Despite the easiness of a git deploy system managing a
series of stages, ie. origin => ci => staging => production, takes some
care and consideration. Additionally, hotfixing changes in the middle of
the chain causes a reordering of commits and different push proceedures
that can car reek havok.

GTA reads git configuration from yml file that should be checked into
source control, assuring the whole team is sharing configurations. There
are easy methods for setting up git remotes, and moving code from stage
to stage. 

## Installation

Add this line to your application's Gemfile:

    gem 'gta'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gta

## Usage

The main use case is via rake task. Include the rake tasks via the
project Rakefile.

    

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
