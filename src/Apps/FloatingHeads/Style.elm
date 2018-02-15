module Apps.FloatingHeads.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li, div, span)
import Css.Icons as Icon
import Css.Utils exposing (..)
import Css.Common exposing (..)
import UI.Colors as Color
import OS.WindowManager.Resources as WM
import Apps.FloatingHeads.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    [ pseudoHeader
    , super
    ]
        |> namespace prefix
        |> (::) crossPrefixes
        |> stylesheet


crossPrefixes : Snippet
crossPrefixes =
    wmClass WM.Window
        [ nest
            [ child (wmClass WM.WindowBody)
            , hover
            , child div
            , child (floatHeadsClass PseudoHeader)
            ]
            [ opacity (int 1) ]
        ]


pseudoHeader : Snippet
pseudoHeader =
    class PseudoHeader
        [ lineHeight (px 16)
        , width (px 150)
        , textAlign center
        , opacity (int 0)
        , transition 1 "opacity" Linear
        , children
            [ class HeaderBtnClose
                [ before
                    [ Icon.windowClose ]
                , color (hex "f25156")
                , Icon.fontFamily
                , textShadow4 (px 1) (px 0) (px 3) Color.black
                , position relative
                , zIndex (int 2)
                ]
            , class HeaderBtnDrag
                [ before
                    [ Icon.moveable ]
                , color Color.bgWindow
                , Icon.fontFamily
                , textShadow4 (px 1) (px 0) (px 3) Color.black
                ]
            ]
        , hover
            [ opacity (int 1) ]
        ]


super : Snippet
super =
    class Super
        [ flexDirection row
        , displayFlex
        , children
            [ class AvatarContainer
                [ display block
                , flex (int 0)
                , width (px 150)
                , children
                    [ class Avatar
                        [ width (px 150)
                        , height (px 150)
                        , borderRadius (pct 100)
                        ]
                    ]
                ]
            , chat
            ]
        ]


chat : Snippet
chat =
    class Chat
        [ flexContainerVert
        , height (px 300)
        , width (px 400)
        , borderRadius (px 8)
        , padding (px 0)
        , marginTop (px -16)
        , zIndex (int 2)
        , backgroundColor Color.bgSelected
        , children
            [ ul
                [ flex (int 1)
                , overflowY auto
                , margin (px 0)
                , padding4 (px 0) (px 0) (px 6) (px 0)
                , children
                    [ li
                        [ display block
                        , child span
                            [ display inlineBlock
                            , backgroundColor <| hex "ada"
                            , borderRadius (px 4)
                            , padding (px 8)
                            ]
                        , padding2 (px 2) (px 8)
                        ]
                    , class To
                        [ textAlign right
                        , child span [ backgroundColor <| hex "aad" ]
                        ]
                    , class Sys
                        [ textAlign center
                        , child span [ backgroundColor <| hex "aaa" ]
                        ]
                    ]
                ]
            , div
                [ flex (int 0)
                , textAlign center
                , child span
                    [ border3 (px 2) solid (hex "ccc")
                    , borderRadius (px 8)
                    , padding (px 4)
                    , margin (px 4)
                    , display inlineBlock
                    ]
                ]
            ]
        ]



-- prefix helpers:


preC : String -> class -> String
preC prefix class =
    prefix ++ (toString class)


wmClass : WM.Classes -> (List Style -> Snippet)
wmClass =
    preC WM.prefix >> class


floatHeadsClass : Classes -> (List Style -> Snippet)
floatHeadsClass =
    preC prefix >> class
