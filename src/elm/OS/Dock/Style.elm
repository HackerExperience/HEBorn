module OS.Dock.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (div)
import Css.Namespace exposing (namespace)
import Utils exposing (flexContainerHorz)

type Id
    = DockMain
    | DockContainer

type Class
    = Item

css =
    (stylesheet << namespace "dock")
        [ id DockMain   
            [ width auto
            , minHeight (px 48)
            , flexContainerHorz
            , justifyContent center
            , after
                [ height (px 16)
                , width (pct 100)
                , backgroundColor (hex "FFF")
                , display block
                , zIndex (int 1)
                , position absolute
                , bottom (px 0)
                , left (px 0)
                , property "content" "''"
                , border3 (px 2) dashed (rgb 11 14 17)
                ]
            ]
        , id DockContainer
            [ position relative
            , zIndex (int 0)
            ]
        , class Item
            [ padding (px 16)
            , borderRadius (pct 100)
            , backgroundColor (hex "F00")
            , zIndex (int 2)
            ]
        ]
