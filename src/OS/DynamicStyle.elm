module OS.DynamicStyle exposing (..)

import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode as Json
import Css.File
import OS.Messages exposing (Msg)
import Game.Storyline.Models as Story
import Game.Storyline.DynamicStyle as Story


view : Story.Model -> Html Msg
view story =
    let
        styleValue =
            (if story.enabled then
                [ Story.dynCss story.missions
                ]
             else
                []
            )
                |> Css.File.compile
                |> (.css)
                |> Json.string
    in
        node "style"
            [ property "innerHTML" styleValue ]
            []
