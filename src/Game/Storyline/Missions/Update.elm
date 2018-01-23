module Game.Storyline.Missions.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Storyline.Missions.Config exposing (..)
import Game.Storyline.Missions.Actions exposing (..)
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Messages exposing (..)
import Game.Storyline.Missions.StepGen exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


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
        |> flip (,) React.none


onStepProceed : ID -> Model -> UpdateResponse msg
onStepProceed stepId model =
    ( setStep (Just (Step stepId (fromStep model.mission stepId))) model
    , React.none
    )
