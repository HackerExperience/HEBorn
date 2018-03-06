module Apps.Browser.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (input, button, form, typeSelector)
import Css.Namespace exposing (namespace)
import UI.Common exposing (flexContainerHorz, flexContainerVert, internalPadding, internalPaddingSz)
import UI.Colors as Colors
import Apps.Browser.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Toolbar
            [ flexContainerHorz
            , lineHeight (int 2)
            , minHeight (px 32) --CHROME HACK
            , children
                [ everything
                    [ flex (int 0)
                    , padding2 (px 0) (px 8)
                    ]
                ]
            , backgroundColor (hex "DDD")
            , borderBottom3 (px 1) solid (hex "CCC")
            , internalPadding
            , margin3 (px -1) (px 0) (px 0)
            ]
        , class AddressBar
            [ flex (int 1)

            -- THIS PADDING FIX A STRANGE INPUT WIDTH BEHAVIOR
            , paddingRight (px 18)
            , children
                [ form
                    [ children
                        [ input
                            [ width (pct 100) ]
                        ]
                    ]
                ]
            ]
        , class Client
            [ flexContainerVert
            , height (pct 100)
            , children
                [ everything
                    [ flex (int 0) ]
                , class PageContent
                    [ flex (int 1)
                    , height (px 0)
                    , overflowY auto
                    ]
                ]
            ]
        , class PageContent
            [ flexContainerVert
            , overflowY auto
            , Css.backgroundColor Colors.white
            ]
        , class AutoHeight
            [ flexContainerVert
            , overflowY visible
            , minHeight (pct 100)
            ]
        , class DummyTitle
            [ lineHeight (int 3)
            , minHeight (px 48) -- CHROME HACK
            , flex (int 0)
            , textAlign center
            , fontWeight bold
            ]
        , class HackingToolkit
            [ flex (int 1)
            , flexContainerVert
            , children
                [ typeSelector "portal"
                    [ flex (int 1)
                    , textAlign center
                    , borderTop3 (px 3) solid (hex "000")
                    , borderBottom3 (px 3) solid (hex "000")
                    , flexContainerVert
                    , justifyContent center
                    , children
                        [ each [ input, button ]
                            [ display inlineBlock ]
                        ]
                    ]
                , typeSelector "actions"
                    [ lineHeight (int 2)
                    , minHeight (px 64) -- CHROME HACK
                    , flex (int 0)
                    , flexContainerHorz
                    , justifyContent center
                    , children
                        [ everything
                            [ textAlign center
                            , margin2 (px 0) internalPaddingSz
                            ]
                        ]
                    ]
                ]
            ]
        , class Btn
            [ cursor pointer
            , withClass InactiveBtn
                [ cursor default
                , color (hex "EEE")
                ]
            ]
        ]
