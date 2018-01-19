module Game.Storyline.Missions.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Storyline.Missions.Config exposing (..)
import Game.Storyline.Missions.Actions exposing (..)
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Messages exposing (..)
import Game.Storyline.Missions.StepGen exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleActionDone action ->
            handleActionDone action model

        HandleStepProceeded next ->
            onStepProceed next model


handleActionDone : Action -> Model -> UpdateResponse msg
handleActionDone action model =
    model
        |> getActions
        |> List.filter ((/=) action)
        |> flip setActions model
        |> Update.fromModel


onStepProceed : ID -> Model -> UpdateResponse msg
onStepProceed stepId model =
    model
        |> setStep (Just (Step stepId (fromStep model.mission stepId)))
        |> Update.fromModel
