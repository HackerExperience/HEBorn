module Apps.ServersGears.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (child)
import Css.Common exposing (flexContainerHorz, flexContainerVert)
import UI.Colors exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class WindowFull
            [ flexContainerVert
            , overflow hidden
            , children
                [ class Toolbar
                    [ flex (int 0)
                    , flexContainerHorz
                    , child everything
                        [ flex (int 1)
                        , textAlign center
                        , borderLeft3 (px 1) solid black
                        , firstChild
                            [ borderLeft (px 0) ]
                        ]
                    , borderBottom3 (px 1) solid black
                    ]
                , class MoboSplit
                    [ flex (int 1)
                    , overflow hidden
                    , displayFlex
                    , children
                        [ class PanelMobo
                            [ flex (int 2)
                            , overflow hidden
                            , padding2 (px 8) (px 8)
                            ]
                        , class PanelInvt
                            [ flex (int 1)
                            , overflowY scroll
                            , borderLeft3 (px 1) solid black
                            ]
                        ]
                    ]
                ]
            ]
        ]
