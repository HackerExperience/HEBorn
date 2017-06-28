module Css.Common exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Utils exposing (pseudoContent)
import Core.Style as Core exposing (prefix)


coreClass : List class -> Html.Attribute msg
coreClass =
    (Html.CssHelpers.withNamespace Core.prefix).class


flexContainerVert : Mixin
flexContainerVert =
    mixin
        [ displayFlex
        , flexDirection column
        ]


flexContainerHorz : Mixin
flexContainerHorz =
    mixin
        [ displayFlex
        , flexDirection row
        ]


globalShadow : Mixin
globalShadow =
    boxShadow5 (px 0) (px 0) (px 8) (px 1) (rgba 0 0 0 0.2)


emptyContent : Mixin
emptyContent =
    pseudoContent "''"


internalPaddingSz : Px
internalPaddingSz =
    (px 8)


internalPadding : Mixin
internalPadding =
    padding internalPaddingSz
