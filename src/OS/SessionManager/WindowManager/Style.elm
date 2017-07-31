module OS.SessionManager.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (globalShadow, flexContainerHorz, flexContainerVert, internalPadding)
import Css.Elements exposing (div)
import Css.Icons as Icon
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (pseudoContent, withAttribute)
import UI.Colors as Colors
import OS.SessionManager.WindowManager.Resources exposing (Classes(..), prefix)


wmBorderRadius : Px
wmBorderRadius =
    (px 4)


addIco : String -> Style -> Style
addIco cond style =
    withAttribute (Css.EQ "data-icon" cond)
        [ before
            [ style ]
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Canvas
            [ flex (int 1)
            , flexContainerVert
            ]
        , class Super
            [ flex (int 1)
            , flexContainerVert
            ]
        , class Window
            [ position (absolute)
            , displayFlex
            , borderRadius wmBorderRadius
            , flexDirection column
            , flex (int 0)
            , withAttribute (Css.EQ "data-decorated" "N")
                [ children
                    [ div
                        [ children
                            [ class WindowHeader
                                [ height (px 16)
                                , marginBottom (px -16)
                                , display block
                                , zIndex (int 1)
                                , position relative
                                ]
                            ]
                        ]
                    ]
                ]
            , withAttribute (Css.EQ "data-decorated" "Y")
                [ globalShadow
                , backgroundColor Colors.bgWindow
                , borderRadius wmBorderRadius
                , color Colors.black
                , children
                    [ class WindowBody
                        [ position relative
                        , flex (int 1)
                        , overflowY hidden
                        , flexContainerVert
                        ]
                    , div
                        [ children
                            [ class WindowHeader
                                [ displayFlex
                                , flexFlow2 row wrap
                                , flex (int 0)
                                , internalPadding
                                , lineHeight (px 16)
                                , minHeight (px 16) --CHROME HACK
                                , fontSize (px 12)
                                , children
                                    [ class HeaderTitle
                                        [ flex (int 1)
                                        , textAlign center
                                        , before
                                            [ Icon.fontFamily
                                            , minWidth (px 14)
                                            , textAlign center
                                            , float left
                                            ]
                                        , addIco "explorer" Icon.explorer
                                        , addIco "logvw" Icon.logvw
                                        , addIco "browser" Icon.browser
                                        , addIco "taskmngr" Icon.taskMngr
                                        , addIco "udb" Icon.dbAdmin
                                        , addIco "connmngr" Icon.connMngr
                                        , addIco "bouncemngr" Icon.bounceMngr
                                        , addIco "moneymngr" Icon.finance
                                        , addIco "hebamp" Icon.hebamp
                                        , addIco "cpanel" Icon.cpanel
                                        , addIco "srvgr" Icon.srvgr
                                        , addIco "locpk" Icon.locpk
                                        , addIco "lanvw" Icon.lanvw
                                        ]
                                    , class HeaderButtons
                                        [ flex (int 0)
                                        , flexContainerHorz
                                        , children
                                            [ class HeaderButton
                                                [ cursor pointer
                                                , flex (int 0)
                                                , minWidth (px 16)
                                                , margin2 (px 0) (px 4)
                                                , display inlineBlock
                                                , textAlign center
                                                , fontSize (px 16)
                                                , marginBottom (px -2)
                                                , color Colors.white
                                                , before
                                                    [ Icon.fontFamily
                                                    , textAlign center
                                                    ]
                                                ]
                                            , class HeaderBtnClose
                                                [ before
                                                    [ Icon.windowClose ]
                                                , color (hex "f25156")
                                                ]
                                            , class HeaderBtnMaximize
                                                [ before
                                                    [ Icon.windowMaximize ]
                                                , color (hex "0ed439")
                                                ]
                                            , class HeaderBtnMinimize
                                                [ before
                                                    [ Icon.windowMinimize ]
                                                , color (hex "ffc109")
                                                ]
                                            ]
                                        ]
                                    , div
                                        [ children
                                            [ class HeaderContextSw
                                                [ margin2 (px 0) (px 8) ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            , withClass Maximizeme
                [ top auto |> important
                , left auto |> important
                , width (pct 100) |> important
                , height auto |> important
                , position relative
                , flex (int 1)
                , borderRadius (px 0)
                , children
                    [ class WindowBody
                        [ borderRadius (px 0)
                        ]
                    , class WindowHeader
                        [ borderRadius (px 0) ]
                    ]
                , withAttribute (Css.EQ "data-decorated" "Y")
                    [ children
                        [ div
                            [ children
                                [ class WindowHeader
                                    [ children
                                        [ class HeaderButtons
                                            [ children
                                                [ class HeaderBtnMaximize
                                                    [ before [ Icon.windowUnmaximize ] ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
