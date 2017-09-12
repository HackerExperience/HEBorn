module Events.Servers.Processes
    exposing
        ( Event(..)
        , StartedData
        , BruteforceFailedData
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
    = Started StartedData
    | Conclusion String
    | BruteforceFailed BruteforceFailedData


type alias StartedData =
    { processId : String
    , type_ : String
    }


type alias BruteforceFailedData =
    { processId : String
    , reason : String
    }


handler : String -> Handler Event
handler event json =
    case event of
        "started" ->
            onStarted json

        "conclusion" ->
            onConclusion json

        "bruteforce_failed" ->
            onBruteforceFailed json

        _ ->
            Nothing



-- internals


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


onBruteforceFailed : Handler Event
onBruteforceFailed =
    let
        decoder =
            decode BruteforceFailedData
                |> required "process_id" string
                |> required "reason" string

        handler json =
            decodeValue decoder json
                |> Result.map BruteforceFailed
                |> notify
    in
        handler
