# HEBorn [![Build Status](https://ci.hackerexperience.com/buildStatus/icon?job=HackerExperience/HEBorn/master)](https://ci.hackerexperience.com/job/HackerExperience/job/HEBorn/job/master) ![](https://tokei.rs/b1/github/hackerexperience/heborn)

HEBorn is the web client for [Hacker Experience 1](https://1.hackerexperience.com).

The codebase here is also the same one for the Hacker Experience 2 client. Once we start releasing the HE2 client, we'll probably split this repository in three: shared logic repository, HE1 client, HE2 client.

## Requirements

You'll need

- [elm](https://elm-lang.org) 0.18
- node and npm (tested with node v7.3.x & npm v4.0.x)
- UNIX-based OS (Linux, MacOS, *BSD). Not tested on Windows.
- [elm-format](https://github.com/avh4/elm-format) for linting
- GNU Make (default make on Linux)
- Patience, we are slowly growing this codebase into a playable, fun game.

## Usage

### Development

Launches development webserver with hot-reload.

```
make setup
make dev
```

Use `make dev-css` to enable hot-reloading of CSS stylesheets.

### Test

```
make test
```

Use `make test-quick` to run a single Fuzz test iteration. Our CI server uses `make test-long` by default.

### Lint

```
make lint
```

Requires elm-format installed on your $PATH.

### Release

Outputs the client static files to `build/`.

```
make setup
make compile
make release
```

## Contributing

Interested in contributing? There are several ways you can help, even if you don't know a thing about computer programming. Please take a look at our [Contribution Guidelines](CONTRIBUTING.md).

## Support
You can get development support on our [online chat](https://chatops.hackerexperience.com/).

If you have any question that could not be responded on the chat by our
contributors, feel free to open an issue.

## License
2015-2017 [Neoart Labs LLC](https://neoartlabs.com).

HEBorn source code is released under the AGPL 3 license.

Check [LICENSE](LICENSE) or [GNU AGPL3](https://www.gnu.org/licenses/agpl-3.0.en.html)
for more information.

[![AGPL3](https://www.gnu.org/graphics/agplv3-88x31.png)](https://www.gnu.org/licenses/agpl-3.0.en.html)
