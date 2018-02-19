module Game.Storyline.Quests.StepActions.DynamicStyle exposing (dynCss)

import Css exposing (Stylesheet, stylesheet)
import Utils.List as List
import UI.DynStyles.Highlight.OS exposing (..)
import UI.DynStyles.Highlight.Explorer exposing (..)


dynCss : Model -> List Stylesheet
dynCss model =
    model
        |> getActions
        |> List.uniqueBy toString
        |> List.map highlights
        |> List.concat


highlight : Action -> List Stylesheet
highlight action =
    case action of
        RunFile fId ->
            [ highlighFileId fId ]

        GoApp app context ->
            [ highlightDockIcon app
            , highlightHeaderContextToggler context
            , highlightWindow app context
            ]
