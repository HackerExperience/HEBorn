module Apps.Explorer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..))
import Css.Common exposing (flexContainerVert, flexContainerHorz, internalPaddingSz)


type Classes
    = Window
    | Nav
    | Content
    | ContentHeader
    | ContentList
    | LocBar
    | ActBtns


css : Stylesheet
css =
    (stylesheet << namespace "fm")
        [ class Window
            [ flexContainerHorz
            , height (pct 100)
            ]
        , class Nav
            [ margin zero
            , padding zero
            , flex (int 1)
            , backgroundColor (hex "C00")
            ]
        , class Content
            [ flex (int 3)
            , flexContainerVert
            ]
        , class ContentHeader
            [ flex (int 0)
            , flexContainerHorz
            , backgroundColor (hex "0C0")
            , paddingLeft internalPaddingSz
            , paddingBottom internalPaddingSz
            ]
        , class LocBar
            [ flex (int 1) ]
        , class ActBtns
            [ flex (int 0)
            , paddingLeft internalPaddingSz
            ]
        , class ContentList
            [ flex (int 1)
            , paddingLeft internalPaddingSz
            , paddingBottom internalPaddingSz
            , backgroundColor (hex "00C")
            ]
        ]
