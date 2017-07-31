module Landing.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
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
            , backgroundImage <| url "https://raw.githubusercontent.com/elementary/wallpapers/master/Photo%20by%20SpaceX.jpg"
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
                    , backgroundColor (rgba 0 0 0 0.4)
                    , color Colors.white
                    , textAlign center
                    ]
                ]
            , opacity (int 0)
            , transition 0.5 "opacity" Linear
            , withClass Loaded
                [ opacity (int 1) ]
            ]
        ]
