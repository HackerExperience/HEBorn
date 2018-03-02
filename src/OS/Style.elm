module OS.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (flexContainerVert, flexContainerHorz, globalShadow)
import Css.Elements exposing (typeSelector, ul, li, div, h6)
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (..)
import Css.Icons as Icons
import UI.Style exposing (clickableBox)
import UI.Colors as Colors
import Css.Colors
import OS.Resources exposing (..)
import OS.Console.Resources as Console


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ id Dashboard
            [ dashboard
            , children
                [ class Session
                    [ flex (int 1)
                    , flexContainerVert
                    , children [ dock ]
                    ]
                , toasts
                , class Version
                    [ position absolute
                    , left (px 0)
                    , bottom (px 0)
                    , color Colors.white
                    ]
                ]
            ]
        , conditional
        ]


dashboard : Style
dashboard =
    batch
        [ width (pct 100)
        , minHeight (pct 100)
        , flexContainerVert
        , position relative
        , zIndex (int 0)
        , backgroundImage <| url "//raw.githubusercontent.com/elementary/wallpapers/master/Photo%20by%20SpaceX.jpg"
        , backgroundSize cover
        , backgroundPosition center
        , fontFamily sansSerif
        , fontFamilies [ "Open Sans" ]
        , Css.fontWeight (int 300)
        ]


dock : Snippet
dock =
    -- This should be on WM.Style
    class Dock
        [ flexContainerHorz
        , justifyContent center
        , width (vw 100)
        , bottom zero
        , zIndex (int 1)
        , minHeight (px 60)
        , paddingTop (px 29)
        , transition 0.15 "margin" EaseOut
        , withClass AutoHide
            [ marginBottom (px -60)
            , hover
                [ marginBottom (px 0) ]
            ]
        ]


conditional : Snippet
conditional =
    id Dashboard
        [ withAttribute (Css.NOT <| Css.EQ gameVersionAttrTag devVersion)
            [ child (class Console.LogConsole)
                [ display none
                , opacity (int 0)
                ]
            ]
        ]
