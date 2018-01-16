module Game.Storyline.Missions.DynamicStyle exposing (dynCss)

import Css exposing (Stylesheet, stylesheet)
import Utils.List as List
import Game.Storyline.Missions.Models exposing (Model, getActions)
import Game.Storyline.Missions.Actions exposing (Action(..))
import UI.DynStyles.Highlight.OS exposing (..)
import UI.DynStyles.Highlight.Explorer exposing (..)


highlights : Action -> List Stylesheet
highlights action =
    case action of
        RunFile fId ->
            [ highlighFileId fId ]

        GoApp app context ->
            [ highlightDockIcon app
            , highlightHeaderContextToggler context
            , highlightWindow app context
            ]


dynCss : Model -> List Stylesheet
dynCss model =
    model
        |> getActions
        |> List.uniqueBy toString
        |> List.map highlights
        |> List.concat
