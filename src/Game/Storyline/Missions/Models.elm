module Game.Storyline.Missions.Models exposing (..)

import Apps.Apps exposing (App(..))
import Game.Shared
import Game.Storyline.Missions.Actions as Actions exposing (..)


type alias ID =
    Game.Shared.ID


type alias Model =
    { mission : Missions
    , goal : Goals
    , step : Maybe Step
    }


type Missions
    = NoMission
    | Tutorial


type Goals
    = NoGoal
    | TutorialIntroduction


type alias Step =
    { current : ID
    , actions : List Action
    , next : ID
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


validateStep : ( ID, ID ) -> Model -> Bool
validateStep ( current, next ) model =
    model.step
        |> Maybe.map (\s -> s.current == current && s.next == next)
        |> Maybe.withDefault False


setStep : Maybe Step -> Model -> Model
setStep newStep model =
    { model | step = newStep }


initStep : ID -> ID -> Maybe Step
initStep from to =
    Just (Step from (fromStep from) to)


initialModel : Model
initialModel =
    { mission = NoMission
    , goal = NoGoal
    , step = Nothing
    }
