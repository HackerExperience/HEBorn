module Setup.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (typeSelector, div, h1, span)
import Css.Namespace exposing (namespace)
import Utils.Css exposing (nest, child)
import Setup.Resources exposing (..)
import UI.Gradients as Gradients
import UI.Icons as Icons
import UI.Colors as Colors


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ selector setupNode
            [ width (vw 100)
            , displayFlex
            , flexDirection row
            , fontFamily sansSerif
            ]
        , selector leftBarNode
            [ minWidth (px 220)
            , flex (int 0)
            , backgroundColor Colors.separator
            ]
        , selector contentNode
            [ flex (int 1)
            , withClass StepPickLocation locationPicker
            , withClass StepWelcome welcome
            ]
        , class Selected
            [ fontWeight bold ]
        ]


welcome : List Style
welcome =
    [ child div
        [ firstChild headerBanner
        , lastChild
            [ padding3 (px 0) (px 16) (px 16) ]
        ]
    ]


locationPicker : List Style
locationPicker =
    [ displayFlex
    , flexDirection column
    , child div
        [ firstChild
            headerBanner
        , lastChild
            [ minHeight (px 140)
            , displayFlex
            , flexDirection column
            , child div
                [ firstChild
                    [ flex (int 1) ]
                , lastChild
                    [ flex (int 0)
                    , textAlign right
                    , displayFlex
                    , flexDirection row
                    , child span
                        [ flex (int 1) ]
                    ]
                ]
            ]
        , nthChild "2"
            [ padding2 (px 0) (px 16) ]
        , backgroundColor Colors.bgWindow
        , padding (px 16)
        ]
    ]


headerBanner : List Style
headerBanner =
    [ minHeight (px 80)
    , Gradients.pinotNoir toTopLeft
    , color Colors.white
    , padding2 (px 2) (px 16)
    , nest [ child h1, before ]
        [ Icons.fontFamily
        , Icons.osLogo
        ]
    ]
