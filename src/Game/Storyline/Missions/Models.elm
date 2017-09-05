module Game.Storyline.Missions.Models exposing (..)

import Apps.Apps exposing (App(..))
import Game.Storyline.Missions.Actions as Actions exposing (..)


type alias SyncID =
    String


type alias Model =
    { mission : Missions
    , goal : Goals
    , step : Maybe Step
    }


type Missions
    = Tutorial


type Goals
    = TutorialIntroduction


type alias Step =
    { current : SyncID
    , actions : List Action
    , next : SyncID
    }


getActions : Model -> List Action
getActions model =
    model.step
        |> Maybe.map (.actions)
        |> Maybe.withDefault []


setActions : List Action -> Model -> Model
setActions actions model =
    case model.step of
        Just step ->
            { model | step = Just { step | actions = actions } }

        Nothing ->
            model


initialModel : Model
initialModel =
    { mission = Tutorial
    , goal = TutorialIntroduction
    , step = Just <| Step "001" (fromSteps "001") "002"
    }
