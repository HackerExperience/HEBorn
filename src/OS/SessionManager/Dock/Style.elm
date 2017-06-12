module OS.SessionManager.Dock.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li)
import Css.Utils exposing (pseudoContent, attrSelector)
import Css.Common exposing (flexContainerHorz, globalShadow, emptyContent)
import Css.Icons as Icon


type Id
    = DockMain
    | DockContainer
    | DockAppContext
    | Visible
    | ClickableWindow


type Class
    = Item
    | ItemIco


css : Stylesheet
css =
    (stylesheet << namespace "dock")
        [ id DockMain
            [ width auto
            , flexContainerHorz
            , justifyContent center
            , after
                [ height (px 16)
                , width (pct 100)
                , property "background" "linear-gradient(to bottom, #e2e2e2 0%,#dbdbdb 50%,#d1d1d1 51%,#fefefe 100%)"
                , display block
                , zIndex (int 1)
                , position absolute
                , bottom (px 0)
                , left (px 0)
                , emptyContent
                , borderRadius4 (pct 100) (pct 100) (px 0) (px 0)
                , globalShadow
                ]
            ]
        , id DockContainer
            [ position relative
            , zIndex (int 0)
            , cursor pointer
            ]
        , class ItemIco
            [ borderRadius (pct 100)
            , padding (px 8)
            , property "background" "linear-gradient(to bottom, #f3c5bd 0%,#e86c57 50%,#ea2803 51%,#ff6600 75%,#c72200 100%)"
            , globalShadow
            , before
                [ Icon.fontFamily
                , fontSize (px 24)
                , minWidth (px 30)
                , minHeight (px 30)
                , textAlign center
                , display inlineBlock
                ]
            ]
        , class Item
            [ margin3 (px 8) (px 4) (px 0)
            , zIndex (int 2)
            , color (hex "FFF")
            , after
                [ emptyContent
                , borderRadius (pct 100)
                , height (px 1)
                , width (px 1)
                , display block
                , marginTop (px -8)
                , position absolute
                , marginLeft (px 21)
                ]
            , hover
                [ children [ class DockAppContext [ display block ] ] ]
            ]
        , attrSelector "dockItemIco"
            "data-icon"
            "="
            "explorer"
            [ before
                [ Icon.explorer ]
            ]
        , attrSelector "dockItemIco"
            "data-icon"
            "="
            "logvw"
            [ before
                [ Icon.logvw ]
            ]
        , attrSelector "dockItemIco"
            "data-icon"
            "="
            "browser"
            [ before
                [ Icon.browser ]
            ]
        , attrSelector "dockItemIco"
            "data-icon"
            "="
            "taskmngr"
            [ before
                [ Icon.taskMngr ]
            ]
        , attrSelector "dockItem"
            "data-hasinst"
            "="
            "Y"
            [ after
                [ padding (px 2)
                , backgroundColor (hex "FFF")
                , globalShadow
                ]
            ]
        , class DockAppContext
            [ display none
            , position absolute
            , bottom (px 0)
            , backgroundColor (rgba 0 0 0 0.5)
            , marginBottom (px 50)
            , width (px 180)
            , maxHeight (vh 80)
            , marginLeft (px ((-180 + 46) / 2)) -- (-DockAppContext.width + dockItem.width) / 2
            , borderRadius (px 8)
            , cursor pointer
            , fontSize (px 12)
            , withClass Visible
                [ display block ]
            , children
                [ ul
                    [ padding (px 8)
                    , listStyle none
                    , children
                        [ li [ paddingLeft (px 8) ] ]
                    ]
                ]
            ]
        , class ClickableWindow
            [ cursor pointer
            , hover [ backgroundColor (rgba 0 0 0 0.5) ]
            ]
        ]
