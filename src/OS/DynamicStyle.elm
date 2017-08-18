module OS.DynamicStyle exposing (..)

import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode as Json
import Css.File
import OS.Messages exposing (Msg)
import Game.Storyline.Missions.Models as Missions
import Game.Storyline.Missions.DynamicStyle as Missions


view : Missions.Model -> Html Msg
view missions =
    missions
        |> Missions.dynCss
        |> List.singleton
        |> Css.File.compile
        |> (.css)
        |> Json.string
        |> property "innerHTML"
        |> List.singleton
        |> node "style"
        |> (\z -> z [])
