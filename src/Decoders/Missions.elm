module Decoders.Missions exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , map
        , succeed
        , fail
        , string
        )
import Json.Decode.Pipeline exposing (decode, resolve)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Storyline.Missions.Missions exposing (..)
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.StepGen exposing (..)


mission : Decoder Model
mission =
    decode recognizeMission
        |> optionalMaybe "mission_id" string
        |> optionalMaybe "step_id" string
        |> resolve


initMission : Mission -> ID -> Model
initMission mission stepId =
    Step stepId (fromStep mission stepId)
        |> Just
        |> Model mission


recognizeMission :
    Maybe String
    -> Maybe String
    -> Decoder Model
recognizeMission mission stepId =
    case ( mission, stepId ) of
        ( Nothing, Nothing ) ->
            succeed <| Model NoMission Nothing

        ( Just missionName, Just stepId ) ->
            missionType missionName
                |> map (flip initMission stepId)

        _ ->
            fail "Unrecgonized mission field pattern"


missionType : String -> Decoder Mission
missionType missionName =
    case missionName of
        "tutorial" ->
            succeed Tutorial

        error ->
            fail <| commonError "mission_type" error
