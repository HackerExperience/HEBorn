module Game.Storyline.StepActions.DynamicStyle exposing (dynCss)

import Css exposing (Stylesheet, stylesheet)
import Game.Storyline.Models exposing (Model, getActions)
import Game.Storyline.StepActions.Shared exposing (Action(..))
import UI.DynStyles.Highlight.OS exposing (..)
import UI.DynStyles.Highlight.Explorer exposing (..)


dynCss : Model -> List Stylesheet
dynCss model =
    model
        |> getActions
        |> List.map highlight
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
