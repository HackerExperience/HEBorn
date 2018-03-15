module Widgets.QuestHelper.View exposing (view)

import Dict
import Html exposing (..)
import Game.Storyline.Models as Story
import Game.Storyline.Shared as Story


view : Story.Model -> Html msg
view story =
    story
        |> Dict.foldl contact []
        |> div []


contact : Story.ContactId -> Story.Contact -> List (Html msg) -> List (Html msg)
contact id contact acu =
    case Story.getStep contact of
        Just step ->
            "TODO"
                |> (++) "You're in step: "
                |> text
                |> flip (::) acu

        Nothing ->
            acu
