module Events.Servers.Processes
    exposing
        ( Event(..)
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
import Decoders.Process
import Game.Servers.Processes.Models exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Events exposing (Handler)


type Event
    = Changed Processes
    | Started ( ID, Process )
    | Conclusion ID
    | BruteforceFailed BruteforceFailedData


type alias BruteforceFailedData =
    { processId : ID
    , status : String
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

        "bruteforce_failed" ->
            onBruteforceFailed json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue Decoders.Process.processDict json
        |> Result.map Changed
        |> notify


onStarted : Handler Event
onStarted json =
    decodeValue Decoders.Process.process json
        |> Result.map Started
        |> notify


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
