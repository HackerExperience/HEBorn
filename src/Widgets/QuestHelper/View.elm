module Widgets.QuestHelper.View exposing (view)

import Html exposing (..)
import Widgets.QuestHelper.Models exposing (..)


view : Model -> Html msg
view { step } =
    step
        |> toString
        |> (++) "You're in step: "
        |> text
