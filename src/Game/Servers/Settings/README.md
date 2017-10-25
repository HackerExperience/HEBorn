Server settings are generic requests to manage settings using generic helix
topics.

There are two generic requests for handling configs:

- **Check:** for validating settings.
- **Set:** for  changing settings.

The current possible settings for servers are:

- **Location**: a map Coordinates record.
- **Name**: the server name.

Generic requests works like non-generic requests, but they receive a param
`(ResponseType -> msg)` to yield commands of `Cmd msg` type.

Some settings may yield data upon checking, the `Types` file also provides
decoders for handling that, like `decodeLocation` for handling `Location`
checks.
