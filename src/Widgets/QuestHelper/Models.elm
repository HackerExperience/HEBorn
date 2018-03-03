module Widgets.QuestHelper.Models exposing (..)

import Game.Storyline.Shared exposing (Step)


type alias Model =
    { step : Step
    , owner : String
    }


type Params
    = OpenForStep Step


getTitle : Model -> String
getTitle { owner } =
    "Quest: " ++ owner
