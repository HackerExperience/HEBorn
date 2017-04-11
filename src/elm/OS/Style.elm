module OS.Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body,  main_, header, footer)
import Css.Namespace exposing (namespace)
import Utils exposing (flexContainerHorz)

type Id
    = Dashboard

css =
    (stylesheet << namespace "os")
        [ id Dashboard   
            [ width (pct 100)
            , minHeight (pct 100)
            , displayFlex
            , flexDirection column
            ]
        , header
            [ backgroundColor (hex "0A0")
            , flexContainerHorz
            , justifyContent flexEnd
            , padding (px 8)
            ]
        , main_
            [ flex (int 1) ]
        , footer
            [ flexContainerHorz
            , justifyContent center
            , position relative
            , minHeight (px 60)
            , marginBottom (px -60)
            , paddingTop (px 8)
            , property "transition" "0.15s margin ease-out" 
            , hover
                [ marginBottom (px 0) ]
            ]
        ]
