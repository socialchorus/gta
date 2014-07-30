[![Code Climate](https://codeclimate.com/github/company/gta.png)](https://codeclimate.com/github/company/gta)

# GTA - the Git Transit Authority

GTA is a git-based deploy tool for moving code from stage to stage.

Heroku has made git deploys an awesome standard. Mislav's git-deploy gem
has made this ease of deploy a possibility for servers that are not
Heroku too. Despite the easiness of a git deploy system managing a
series of stages, ie. origin => ci => staging => production, takes some
care and consideration. Additionally, hot-fixing changes in the middle of
the chain causes a reordering of commits and different push procedures
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

Make sure you create a `gta.yml` file in your config directory that looks something like this:

    name: app-name

    stages:
      origin:
        repository: git@github.com:username/repo.git

      staging:
        source: origin
        repository: git@heroku.com:app-name-staging.git

      qa:
        source: staging
        repository: git@heroku.com:app-name-qa.git

      production:
        source: qa
        repository: git@heroku.com:app-name-production.git

**Note:** make sure to add `require 'gta/tasks'` to your Rakefile


## Usage

The main use case is via rake task. Include the rake tasks via the
project Rakefile.



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
