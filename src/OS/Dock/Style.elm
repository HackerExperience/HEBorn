module OS.Dock.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (pseudoContent, attrSelector)
import Css.Common exposing (flexContainerHorz, globalShadow, emptyContent)
import Css.Icons as Icon


type Id
    = DockMain
    | DockContainer


type Class
    = Item


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
        , class Item
            [ margin3 (px 20) (px 4) (px 0)
            , padding (px 8)
            , borderRadius (pct 100)
            , property "background" "linear-gradient(to bottom, #f3c5bd 0%,#e86c57 50%,#ea2803 51%,#ff6600 75%,#c72200 100%)"
            , zIndex (int 2)
            , color (hex "FFF")
            , globalShadow
            , before
                [ Icon.fontFamily
                , fontSize (px 24)
                , minWidth (px 30)
                , minHeight (px 30)
                , textAlign center
                , display inlineBlock
                ]
            , after
                [ emptyContent
                , borderRadius (pct 100)
                , height (px 1)
                , width (px 1)
                , display block
                , margin2 (px 0) auto
                ]
            ]
        , attrSelector "dockItem"
            "data-icon"
            "="
            "explorer"
            [ before
                [ Icon.explorer ]
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
        ]
