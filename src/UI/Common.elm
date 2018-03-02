module UI.Common exposing (..)

import Css exposing (..)
import Utils.Css exposing (pseudoContent)


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
    boxShadow4 (px 0) (px 3) (px 15) (rgba 0 0 0 0.2)


emptyContent : Style
emptyContent =
    pseudoContent "''"


internalPaddingSz : Px
internalPaddingSz =
    (px 8)


internalPadding : Style
internalPadding =
    padding internalPaddingSz
