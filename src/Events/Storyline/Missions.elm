module Events.Storyline.Missions exposing (Event(..), handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , andThen
        , succeed
        , maybe
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Events exposing (Handler, notify, commonError)
import Game.Storyline.Missions.Actions exposing (fromStep)
import Game.Storyline.Missions.Models exposing (..)


type alias NowAfterLater =
    ( ID, ID, ID )


type Event
    = StepDone NowAfterLater


handler : String -> Handler Event
handler event json =
    case event of
        "stepdone" ->
            onStepDone json

        _ ->
            Nothing


decoder : Decoder Model
decoder =
    decode (,,,)
        |> optional "mission" (maybe string) Nothing
        |> optional "goals" (maybe string) Nothing
        |> optional "current" (maybe string) Nothing
        |> optional "next" (maybe string) Nothing
        |> andThen
            (\themall ->
                case themall of
                    ( Just "tutorial", Just "intro", Just current, Just next ) ->
                        Step current (fromStep current) next
                            |> Just
                            |> Model Tutorial TutorialIntroduction
                            |> succeed

                    _ ->
                        succeed <| Model NoMission NoGoal Nothing
            )



-- internals


onStepDone : Handler Event
onStepDone json =
    decodeValue stepDone json
        |> Result.map StepDone
        |> notify


stepDone : Decoder NowAfterLater
stepDone =
    decode (,,)
        |> required "current" string
        |> required "next" string
        |> required "nextnext" string
