module Widgets.QuestHelper.Models exposing (..)

import Game.Storyline.Shared exposing (Step)


type alias Model =
    { step : Step
    , owner : String
    }


getTitle : Model -> String
getTitle { owner } =
    "Quest: " ++ owner
