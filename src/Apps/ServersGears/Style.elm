module Apps.ServersGears.Style exposing (..)

import Css exposing (..)
import Css.Colors exposing (black)
import Css.Elements exposing (div, svg)
import Css.Namespace exposing (namespace)
import Utils.Css exposing (child)
import UI.Common exposing (flexContainerHorz, flexContainerVert)
import UI.Colors exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class WindowFull
            [ flexContainerVert
            , overflow hidden
            , height (pct 100)
            , children
                [ class Toolbar
                    [ flex (int 0)
                    , textAlign center
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
                            , flexContainerVert
                            , justifyContent center
                            , alignItems center
                            , children
                                [ class MoboContainer
                                    [ maxHeight (pct 100)
                                    , overflow hidden
                                    , textAlign center
                                    , flex (int 1)
                                    , child svg
                                        [ width (pct 100)
                                        , height (pct 100)
                                        ]
                                    ]
                                ]
                            ]
                        , class PanelInvt
                            [ flex (int 1)
                            , overflowY auto
                            , borderLeft3 (px 1) solid black
                            , child (class Group)
                                [ borderTop3 (px 1) solid black
                                , padding (px 8)
                                , firstChild
                                    [ borderTop (px 0) ]
                                , child (class GroupName)
                                    [ textAlign center
                                    , fontWeight bold
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , class Highlight
            [ color hyperlink ]
        ]
