module Game.Storyline.Missions.Models exposing (..)

import Apps.Apps exposing (App(..))
import Game.Shared
import Game.Storyline.Missions.Actions exposing (Action)
import Game.Storyline.Missions.Missions exposing (Mission(NoMission))
import Game.Storyline.Missions.StepGen as Actions


type alias ID =
    Game.Shared.ID


type alias Model =
    { mission : Mission
    , step : Maybe Step
    }


type alias Step =
    { id : ID
    , actions : List Action
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


validateStep : ID -> Model -> Bool
validateStep current model =
    model.step
        |> Maybe.map (\s -> s.id == current)
        |> Maybe.withDefault False


setStep : Maybe Step -> Model -> Model
setStep newStep model =
    { model | step = newStep }


initialModel : Model
initialModel =
    { mission = NoMission
    , step = Nothing
    }
