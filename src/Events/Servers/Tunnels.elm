module Events.Servers.Tunnels exposing (Event(..), handler)

import Json.Decode exposing (Decoder, Value, decodeValue, list, maybe, string)
import Json.Decode.Pipeline exposing (optional, required, decode)
import Utils.Events exposing (Handler, notify)
import Decoders.Tunnels


type Event
    = Changed Decoders.Tunnels.Index


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue Decoders.Tunnels.index json
        |> Result.map Changed
        |> notify
