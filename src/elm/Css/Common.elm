module Css.Common exposing (..)

import Css exposing (..)
import Css.Utils exposing (pseudoContent)


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
