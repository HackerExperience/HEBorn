module OS.WindowManager.Style exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (div)
import Css.Namespace exposing (namespace)
import Utils.Css as Css exposing (pseudoContent, withAttribute, nest, child)
import OS.WindowManager.Resources exposing (..)
import UI.Colors as Colors
import UI.Common exposing (globalShadow, flexContainerHorz, flexContainerVert, internalPadding)
import UI.Icons as Icons


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
        [ before [ Icons.windowUnmaximize ] ]
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
            [ Icons.fontFamily
            , minWidth (px 14)
            , textAlign center
            , float left
            ]
        , addIco "explorer" Icons.explorer
        , addIco "logvw" Icons.logvw
        , addIco "browser" Icons.browser
        , addIco "taskmngr" Icons.taskMngr
        , addIco "udb" Icons.dbAdmin
        , addIco "connmngr" Icons.connMngr
        , addIco "bouncemngr" Icons.bounceMngr
        , addIco "moneymngr" Icons.finance
        , addIco "hebamp" Icons.hebamp
        , addIco "cpanel" Icons.cpanel
        , addIco "srvgr" Icons.srvgr
        , addIco "locpk" Icons.locpk
        , addIco "lanvw" Icons.lanvw
        , addIco "email" Icons.email
        , addIco "bug" Icons.bug
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
                    [ Icons.fontFamily
                    , textAlign center
                    ]
                ]
            , class HeaderBtnPin
                [ before [ Icons.windowPin ]
                , color (hex "c1c1c1")
                ]
            , class HeaderBtnClose
                [ before [ Icons.windowClose ]
                , color (hex "f25156")
                ]
            , class HeaderBtnMaximize
                [ before [ Icons.windowMaximize ]
                , color (hex "0ed439")
                ]
            , class HeaderBtnMinimize
                [ before [ Icons.windowMinimize ]
                , color (hex "ffc109")
                ]
            ]
        ]


sidebar : Snippet
sidebar =
    class Sidebar
        [ flex (int 0)
        , flexContainerHorz
        , alignItems center
        , height (pct 100)
        ]
