module Landing.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, button, label, input)
import Css.Utils exposing (Easing(Linear), transition)
import UI.Colors as Colors
import Landing.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ id viewId
            [ width (vw 100) ]
        , id introId
            [ color Colors.terminalPhosphor
            , backgroundColor Colors.black
            , height (vh 100)
            ]
        , id displayManagerId
            [ displayFlex
            , alignItems center
            , justifyContent center
            , position absolute
            , flexDirection column
            , top (px 0)
            , left (px 0)
            , width (vw 100)
            , height (vh 100)
            , backgroundImage <| url "//raw.githubusercontent.com/elementary/wallpapers/master/Photo%20by%20SpaceX.jpg"
            , backgroundSize cover
            , fontFamily sansSerif
            , fontFamilies [ "Open Sans" ]
            , Css.fontWeight (int 300)
            , children
                [ everything
                    [ borderRadius (px 8)
                    , border3 (px 1) solid Colors.black
                    , margin2 (px 8) (px 0)
                    , padding (px 8)
                    , backgroundColor (rgba 0 0 0 0.7)
                    , color Colors.white
                    , textAlign center
                    , display block
                    ]
                ]
            , descendants
                [ each [ input, button ] breezeDarkInput
                ]
            , opacity (int 0)
            , transition 0.5 "opacity" Linear
            , withClass Loaded
                [ opacity (int 1) ]
            ]
        , class Input
            [ displayFlex
            , flexDirection row
            , children
                [ label
                    [ flex (int 1)
                    , textAlign right
                    , marginRight (px 8)
                    ]
                , input
                    [ flex (int 0) ]
                ]
            ]
        ]


breezeDarkInput : List Style
breezeDarkInput =
    [ backgroundImage <| none
    , backgroundColor (rgb 35 38 41)
    , color (rgb 239 240 241)
    , border3 (px 1) solid (rgb 49 54 59)
    , borderRadius (px 4)
    , padding2 (px 4) (px 8)
    ]
