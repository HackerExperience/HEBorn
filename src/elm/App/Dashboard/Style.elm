module App.Dashboard.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, main_)
import Css.Namespace exposing (namespace)


type CssClasses
    = NavBar


type CssIds
    = Page
--------
css =
    (stylesheet << namespace "dreamwriter")
    [ body
        [ overflowX auto
        , minWidth (px 1280)
        ]
    , id Page
        [ backgroundColor (rgb 200 128 64)
        , color (hex "CCFFFF")
        , width (pct 100)
        , height (pct 100)
        , boxSizing borderBox
        , padding (px 8)
        , margin zero
        ]
    , class NavBar
        [ margin zero
        , padding zero
        , children
            [ li
                [ (display inlineBlock) |> important
                , color primaryAccentColor
                ]
            ]
        ]
    , main_ [ backgroundColor (hex "000") ]
    ]


primaryAccentColor =
    hex "ccffaa"
