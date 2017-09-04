module Events.Servers.Processes
    exposing
        ( Event(..)
        , StartedData
        , handler
        )

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
    | Started StartedData
    | Conclusion String


type alias StartedData =
    { processId : String
    , type_ : String
    }


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        "started" ->
            onStarted json

        "conclusion" ->
            onConclusion json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed


onStarted : Handler Event
onStarted =
    let
        constructor proc type_ =
            { processId = proc
            , type_ = type_
            }

        decoder =
            decode constructor
                |> required "process_id" string
                |> required "type" string

        handler json =
            decodeValue decoder json
                |> Result.map Started
                |> notify
    in
        handler


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
