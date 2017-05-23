module Apps.Browser.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, form)
import Css.Common exposing (flexContainerHorz, flexContainerVert, internalPadding, internalPaddingSz)
import Css.Icons as Icon


type Classes
    = Window
    | Content
    | Toolbar
    | AddressBar
    | Client
    | PageContent
    | LoginPageHeader
    | LoginPageForm
    | LoginPageFooter


css : Stylesheet
css =
    (stylesheet << namespace "browser")
        [ class Toolbar
            [ flexContainerHorz
            , lineHeight (int 2)
            , children
                [ everything
                    [ flex (int 0)
                    , padding2 (px 0) (px 8)
                    ]
                ]
            , backgroundColor (hex "DDD")
            , borderBottom3 (px 1) solid (hex "CCC")
            , internalPadding
            , margin3 (px -8) (px -8) (px 8)
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
                    [ flex (int 1) ]
                ]
            ]
        , class PageContent
            [ margin (px -8)
            , flexContainerVert
            ]
        , class Window
            [ height (pct 100) ]
        , class LoginPageHeader
            [ lineHeight (int 3)
            , flex (int 0)
            , textAlign center
            ]
        , class LoginPageForm
            [ flex (int 1)
            , textAlign center
            , borderTop3 (px 3) solid (hex "000")
            , borderBottom3 (px 3) solid (hex "000")
            , flexContainerVert
            , justifyContent center
            ]
        , class LoginPageFooter
            [ lineHeight (int 2)
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
