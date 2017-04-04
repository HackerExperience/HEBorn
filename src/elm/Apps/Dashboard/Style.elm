module Apps.Dashboard.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, main_, header, footer, nav)
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
    , header
          [
          ]
    , main_
          [ backgroundColor (hex "CCC") ]
    ]


primaryAccentColor =
    hex "ccffaa"
