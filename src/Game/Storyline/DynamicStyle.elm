module Game.Storyline.DynamicStyle exposing (dynCss)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (withAttribute)
import Utils.List as List
import Game.Storyline.Models exposing (Missions, Objective(..))
import Apps.Explorer.Resources as Explorer


highlights : Objective -> List Snippet
highlights mission =
    case mission of
        RunFile fId ->
            namespace Explorer.prefix
                [ class Explorer.CntListEntry
                    [ withAttribute (Css.EQ Explorer.idAttrKey fId)
                        [ backgroundColor (hex "D3D")
                        ]
                    ]
                ]


dynCss : Missions -> Stylesheet
dynCss missions =
    missions
        |> List.map (.now)
        |> List.concat
        |> List.uniqueBy toString
        |> List.map highlights
        |> List.concat
        |> stylesheet
