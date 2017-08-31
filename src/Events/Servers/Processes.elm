module Events.Servers.Processes exposing (Event(..), handler)

import Utils.Events exposing (Handler, notify)
import Json.Decode
    exposing
        ( decodeValue
        , oneOf
        , map
        , maybe
        , lazy
        , list
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Events exposing (Handler)


type Event
    = Changed
    | Conclusion String


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        "conclusion" ->
            onConclusion json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed


onConclusion : Handler Event
onConclusion json =
    let
        decoder =
            decode identity
                |> required "process_id" string
    in
        decodeValue decoder json
            |> Result.map Conclusion
            |> notify
