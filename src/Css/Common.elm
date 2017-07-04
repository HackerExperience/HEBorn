module Css.Common exposing (..)

import Html
import Html.CssHelpers
import Css exposing (..)
import Css.Utils exposing (pseudoContent)


flexContainerVert : Style
flexContainerVert =
    batch
        [ displayFlex
        , flexDirection column
        ]


flexContainerHorz : Style
flexContainerHorz =
    batch
        [ displayFlex
        , flexDirection row
        ]


globalShadow : Style
globalShadow =
    boxShadow5 (px 0) (px 0) (px 8) (px 1) (rgba 0 0 0 0.2)


emptyContent : Style
emptyContent =
    pseudoContent "''"


internalPaddingSz : Px
internalPaddingSz =
    (px 8)


internalPadding : Style
internalPadding =
    padding internalPaddingSz
