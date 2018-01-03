module Game.Storyline.Missions.DynamicStyle exposing (dynCss)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (withAttribute, nest)
import Utils.List as List
import Utils.Html.Attributes exposing (activeContextValue, appAttrTag)
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Actions exposing (Action(..))
import OS.Resources as OS
import OS.SessionManager.Dock.Resources as Dock
import OS.SessionManager.WindowManager.Resources as WM
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

        GoApp app context ->
            namespace Dock.prefix
                [ class Dock.ItemIco
                    [ withAttribute (Css.EQ Dock.appIconAttrTag (Apps.icon app))
                        [ borderRadius (px 0) |> important
                        , backgroundImage none |> important
                        , backgroundColor (hex "F00")
                        ]
                    ]
                ]
                ++ namespace OS.prefix
                    [ class OS.Context
                        [ withAttribute (Css.NOT (Css.BOOL OS.headerContextActiveAttrTag))
                            [ backgroundColor (hex "F00") ]
                        ]
                    ]
                ++ namespace WM.prefix
                    [ class WM.Window
                        [ nest
                            [ withAttribute (Css.EQ appAttrTag (Apps.name app))
                            , context
                                |> activeContextValue
                                |> Css.EQ "context"
                                |> withAttribute
                            ]
                            [ backgroundColor (hex "F00") ]
                        ]
                    ]


dynCss : Model -> Stylesheet
dynCss model =
    model
        |> getActions
        |> List.uniqueBy toString
        |> List.map highlights
        |> List.concat
        |> stylesheet
