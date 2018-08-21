module Apps.Browser.Pages.Bank.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import UI.Common 
    exposing 
        ( flexContainerHorz
        , flexContainerVert
        , internalPadding
        )
import Css.Elements exposing (input, button)
import Apps.Browser.Pages.Bank.Resources exposing (Classes(..), prefix)

css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class MainContainer
            [ width (pct 98)
            , height (pct 100)
            , overflowX hidden
            , overflowY auto
            , internalPadding
            , children
                [ class Header
                    [ flexContainerHorz
                    , height (pct 10)
                    , width (pct 100)
                    ]
                , class MiddleContainer
                    [ flexContainerVert
                    , height (pct 80)
                    , width (pct 100)
                    , justifyContent spaceBetween 
                    , children 
                        [ class LoginForm
                            [ flexContainerVert
                            , height (px 150)
                            , width (px 310)
                            , justifyContent center
                            , alignItems center
                            , margin2 (px 0) auto
                            , children
                                [ each [ input ]
                                    [ width (px 150)
                                    , height (px 16)
                                    , marginBottom (px 8)
                                    ]
                                , each [ button ]
                                    [ height (px 16)
                                    ]
                                ]
                            ]
                        , class TransferForm
                            [ flexContainerVert
                            , height (px 150)
                            , width (px 310)
                            , justifyContent center
                            , alignItems center
                            , margin2 (px 0) auto
                            , children
                                [ each [ input ]
                                    [ width (px 150)
                                    , height (px 24)
                                    , marginBottom (px 8)
                                    ]
                                ]
                            ]
                        , class BalanceContainer
                            [ flexContainerHorz
                            , width (pct 100)
                            , alignItems flexEnd
                            , height (px 16)
                            ]
                        , class ActionsContainer
                            [ flexContainerHorz
                            , width (pct 100)
                            , height (px 24)
                            , children 
                                [ each [ button ]
                                    [ marginRight (px 8)
                                    ]
                                ]
                            ]
                        ]
                    ]
                , class Footer
                    [ flexContainerHorz
                    , height (pct 10)
                    , width (pct 100)
                    ]
                ]
            ]
        ]