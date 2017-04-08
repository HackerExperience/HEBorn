module OS.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body, li, main_, header, footer, nav)
import Css.Namespace exposing (namespace)


css =
    (stylesheet << namespace "os")
    [ header
          [
          ]
    , main_
          [ backgroundColor (hex "CCC") ]
    ]
