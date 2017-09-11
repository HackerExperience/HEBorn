module Events.Account.Story exposing (Event(..), handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Handler, notify, commonError)
import Game.Storyline.Missions.Models exposing (..)


type alias NowAfterLater =
    ( SyncID, SyncID, SyncID )


type Event
    = StepDone NowAfterLater


handler : String -> Handler Event
handler event json =
    case event of
        "stepdone" ->
            onStepDone json

        _ ->
            Nothing



-- internals


onStepDone : Handler Event
onStepDone json =
    decodeValue decoder json
        |> Result.map StepDone
        |> notify


decoder : Decoder NowAfterLater
decoder =
    decode (\a b c -> ( a, b, c ))
        |> required "current" string
        |> required "next" string
        |> required "nextnext" string
