# Heroku Symbol

Enable symbolic attachment rendering of the config_var endpoint in the
`heroku config` index view only.

Install it with:

```sh
heroku plugins:install git@github.com:heroku/heroku-symbol.git
```

## Why

Resource symbols provide a number of improvements to the user
experience:

* Allow unambiguous creation of attachments between apps via
  `config:set`.

* Obscure sensitive connection strings and secrets when printing to
  the console.

* Prevent secrets from leaking into bash history as customers use
  `config:set` with cut-and-paste from `config`.

* Show meaningful values to user that help them associate config vars
  with the resources they own.

* Allow showing meaningful errors to users if they try to create an
  invalid attachment.

They aren't designed to completely block access to sensitive
information and will still provide a mechanism for users to reveal
their secrets when necessary.

The prior text was adapted from a
[writeup](https://gist.github.com/brandur/22d1619aad74d08d2ad0) by
Brandur Leach.

## Examples

Before:

```sh
$ heroku config -a my-app
=== my-app Config Vars
DATABASE_URL:               postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
HEROKU_POSTGRESQL_GOLD_URL: postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
```

After:

```sh
$ heroku config -a my-app
=== my-app Config Vars
DATABASE_URL:               @ref:imagining-nobly-9265:url
HEROKU_POSTGRESQL_GOLD_URL: @ref:imagining-nobly-9265:url
```

One can suppress `heroku-symbol`'s behavior even after it is installed
by setting `DISABLE_HEROKU_SYMBOL=1`:

```sh
$ DISABLE_HEROKU_SYMBOL=1 heroku config -a my-app
=== my-app Config Vars
DATABASE_URL:               postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
HEROKU_POSTGRESQL_GOLD_URL: postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
```

## Implementation

What is included is a copy of the original `heroku config` commmand
implementation, with the minor addition of including the
`symbolic=true` parameter:

```ruby
      vars = if options[:shell]
               api.get_config_vars(app).body
             else
               api.request(
                 :expects  => 200,
                 :method   => :get,
                 :path     => "/apps/#{app}/config_vars",
                 :query    => { "symbolic" => true }
               ).body
             end
```

Note that the symbol behavior is suppressed should one use the `-s`
a.k.a. `--shell`:

```sh
$ heroku config -s -a my-app
DATABASE_URL=postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
HEROKU_POSTGRESQL_GOLD_URL=postgres://AHH:SECRETS@ec2-107-20-137-251.compute-1.amazonaws.com:5592/d8juojj9drtgve
```
