module Widgets.QuestHelper.Models exposing (..)

import Game.Storyline.Shared exposing (Step)


type alias Model =
    { step : Maybe Step }


type Params
    = OpenForStep Step


initialModel : Model
initialModel =
    { step = Nothing }
