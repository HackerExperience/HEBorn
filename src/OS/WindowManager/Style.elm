module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Common exposing (globalShadow, flexContainerHorz, flexContainerVert, internalPadding)
import Css.Elements exposing (div)
import Css.Icons as Icon
import Css.Namespace exposing (namespace)
import Css.Utils as Css exposing (pseudoContent, withAttribute, nest, child)
import UI.Colors as Colors
import OS.WindowManager.Resources exposing (..)


wmBorderRadius : Px
wmBorderRadius =
    (px 4)


addIco : String -> Style -> Style
addIco cond style_ =
    withAttribute (Css.EQ appIconAttrTag cond)
        [ before
            [ style_ ]
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
            , displayFlex
            , flexDirection rowReverse
            , alignItems center
            , children [ sidebar ]
            ]
        , window
        ]


window : Snippet
window =
    class Window
        [ position (absolute)
        , zIndex (int 0)
        , displayFlex
        , borderRadius wmBorderRadius
        , flexDirection column
        , flex (int 0)
        , focus [ outline none ]
        , withAttribute (Css.NOT (Css.BOOL decoratedAttrTag))
            undecoratedWindow
        , withAttribute (Css.BOOL decoratedAttrTag)
            decoratedWindow
        , withClass Maximizeme
            maximizedWindow
        ]


undecoratedWindow : List Style
undecoratedWindow =
    [ nest
        [ child div, child (class WindowHeader) ]
        [ height (px 16)
        , marginBottom (px -16)
        , display block
        , zIndex (int 1)
        , position relative
        ]
    ]


decoratedWindow : List Style
decoratedWindow =
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
        , div [ children [ header ] ]
        ]
    ]


maximizedWindow : List Style
maximizedWindow =
    [ top auto |> important
    , left auto |> important
    , height (pct 100) |> important
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
    , nest
        [ withAttribute (Css.BOOL decoratedAttrTag)
        , child div
        , child (class WindowHeader)
        , child (class HeaderButtons)
        , child (class HeaderBtnMaximize)
        ]
        [ before [ Icon.windowUnmaximize ] ]
    ]


header : Snippet
header =
    class WindowHeader
        [ displayFlex
        , flexFlow2 row wrap
        , flex (int 0)
        , internalPadding
        , lineHeight (px 16)
        , minHeight (px 16) --CHROME HACK
        , fontSize (px 12)
        , children
            [ headerTitle
            , headerBtns
            , div
                [ child (class HeaderContextSw)
                    [ margin2 (px 0) (px 8) ]
                ]
            ]
        ]


headerTitle : Snippet
headerTitle =
    class HeaderTitle
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
        , addIco "email" Icon.email
        , addIco "bug" Icon.bug
        ]


headerBtns : Snippet
headerBtns =
    class HeaderButtons
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
            , class HeaderBtnPin
                [ before [ Icon.windowPin ]
                , color (hex "c1c1c1")
                ]
            , class HeaderBtnClose
                [ before [ Icon.windowClose ]
                , color (hex "f25156")
                ]
            , class HeaderBtnMaximize
                [ before [ Icon.windowMaximize ]
                , color (hex "0ed439")
                ]
            , class HeaderBtnMinimize
                [ before [ Icon.windowMinimize ]
                , color (hex "ffc109")
                ]
            ]
        ]


sidebar : Snippet
sidebar =
    class Sidebar
        [ flex (int 0)
        ]
