module Game.Storyline.Missions.DynamicStyle exposing (dynCss)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (withAttribute)
import Utils.List as List
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Actions exposing (Action(..))
import OS.SessionManager.Dock.Resources as Dock
import Apps.Models as Apps
import Apps.Explorer.Resources as Explorer


highlights : Action -> List Snippet
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

        RunApp app ->
            namespace Dock.prefix
                [ class Dock.ItemIco
                    [ withAttribute (Css.EQ "data-icon" (Apps.icon app))
                        [ borderRadius (px 0) |> important
                        , backgroundImage none |> important
                        , backgroundColor (hex "F00")
                        ]
                    ]
                ]


dynCss : Model -> Stylesheet
dynCss missions =
    missions
        |> List.map (.now)
        |> List.concat
        |> List.uniqueBy toString
        |> List.map highlights
        |> List.concat
        |> stylesheet
