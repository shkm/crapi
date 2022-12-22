# 📠 Crapi

Crapi [/ˈkrapi/] exposes a JSON or YAML file via a simple HTTP API for use as a basic read-only key-value store. It might be useful for serving up static data that doesn't change very often.

Also, it's written in Crystal! Yay!

⚠️  Very WIP. Restructure and tests to follow.

## Installation

TODO.

1. Grab the binary
2. ???
3. Maybe profit

## Usage

With a `data.yml` file in the current working directory, run crapi:

```
crapi
```

Your yaml will be exposed on port 3000. For example, with this yaml file:

```yaml
foo:
  bar:
    baz: Hi ma
```

You'll receive this response:

```
> curl localhost:3000/foo/bar/baz
{"data":"Hi ma"}⏎
```

If the key is missing, the server simply returns a 404.

## Development

1. Have crystal
2. TODO

## Contributing

1. Fork it (<https://github.com/shkm/crapi/fork>)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'feat: add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Schembri](https://github.com/shkm) - creator and maintainer
