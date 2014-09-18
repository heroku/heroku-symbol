# Heroku Symbol

Enable symbolic attachment rendering of the config_var endpoint in the
`heroku config` index view only.

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

What is included is a copy of the original `heroku config` commmand implementation, with the minor addition of including the `symbolize=true` parameter:

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
