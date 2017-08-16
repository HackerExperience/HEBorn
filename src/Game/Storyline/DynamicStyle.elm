module Game.Storyline.DynamicStyle exposing (dynCss)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (withAttribute)
import Game.Storyline.Models exposing (Missions, Mission(..))
import Apps.Explorer.Resources as Explorer


highlights : Mission -> List Snippet
highlights mission =
    case mission of
        FirstMission ->
            namespace Explorer.prefix
                [ class Explorer.CntListEntry
                    [ withAttribute (Css.EQ Explorer.idAttrKey "003")
                        [ backgroundColor (hex "D3D")
                        ]
                    ]
                ]


dynCss : Missions -> Stylesheet
dynCss missions =
    missions
        |> List.map highlights
        |> List.concat
        |> stylesheet
