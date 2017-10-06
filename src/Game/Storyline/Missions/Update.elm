module Game.Storyline.Missions.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Missions.Actions exposing (..)
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Messages exposing (..)
import Game.Storyline.Missions.StepGen exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        ActionDone action ->
            onActionDone action model

        StepProceed next ->
            onStepProceed next model


onActionDone : Action -> Model -> UpdateResponse
onActionDone action model =
    model
        |> getActions
        |> List.filter ((/=) action)
        |> flip setActions model
        |> Update.fromModel


requestSync : Cmd Msg
requestSync =
    -- TODO
    Cmd.none


onStepProceed : ID -> Model -> UpdateResponse
onStepProceed stepId model =
    model
        |> setStep (Just (Step stepId (fromStep model.mission stepId)))
        |> Update.fromModel
