module OS.SessionManager.Dock.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (ul, li)
import Css.Utils as Css exposing (pseudoContent, withAttribute)
import Css.Common exposing (flexContainerHorz, globalShadow, emptyContent)
import Css.Icons as Icon
import OS.SessionManager.Dock.Resources exposing (Classes(..), prefix)


addIco : String -> Style -> Style
addIco cond style =
    withAttribute
        (Css.EQ "data-icon" cond)
        [ before
            [ style ]
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Main
            [ width auto
            , flexContainerHorz
            , justifyContent center
            , after
                [ height (px 16)
                , width (pct 100)
                , backgroundImage <|
                    linearGradient2
                        toBottom
                        (stop2 (hex "e2e2e2") (pct 0))
                        (stop2 (hex "dbdbdb") (pct 50))
                        [ (stop2 (hex "d1d1d1") (pct 51))
                        , (stop <| hex "fefefe")
                        ]
                , display block
                , zIndex (int 1)
                , position absolute
                , bottom (px 0)
                , left (px 0)
                , emptyContent
                , borderRadius4 (pct 100) (pct 100) (px 0) (px 0)
                , globalShadow
                ]
            ]
        , class Container
            [ position relative
            , zIndex (int 0)
            , cursor pointer
            ]
        , class ItemIco
            [ borderRadius (pct 100)
            , padding (px 8)
            , backgroundImage <|
                linearGradient2
                    toBottom
                    (stop2 (hex "f3c5bd") (pct 0))
                    (stop2 (hex "e86c57") (pct 50))
                    [ (stop2 (hex "ff6600") (pct 51))
                    , (stop <| hex "c72200")
                    ]
            , globalShadow
            , before
                [ Icon.fontFamily
                , fontSize (px 24)
                , minWidth (px 30)
                , minHeight (px 30)
                , textAlign center
                , display inlineBlock
                ]
            , addIco "explorer" Icon.explorer
            , addIco "logvw" Icon.logvw
            , addIco "browser" Icon.browser
            , addIco "taskmngr" Icon.taskMngr
            , addIco "udb" Icon.dbAdmin
            , addIco "connmngr" Icon.connMngr
            , addIco "bouncemngr" Icon.bounceMngr
            , addIco "moneymngr" Icon.finance
            ]
        , class Item
            [ margin3 (px 8) (px 4) (px 0)
            , zIndex (int 2)
            , color (hex "FFF")
            , after
                [ emptyContent
                , borderRadius (pct 100)
                , height (px 1)
                , width (px 1)
                , display block
                , marginTop (px -8)
                , position absolute
                , marginLeft (px 21)
                ]
            , hover
                [ children [ class AppContext [ display block ] ] ]
            , withAttribute (Css.EQ "data-hasinst" "Y")
                [ after
                    [ padding (px 2)
                    , backgroundColor (hex "FFF")
                    , globalShadow
                    ]
                ]
            ]
        , class AppContext
            [ display none
            , position absolute
            , bottom (px 0)
            , backgroundColor (rgba 0 0 0 0.5)
            , marginBottom (px 50)
            , width (px 180)
            , maxHeight (vh 80)
            , marginLeft (px ((-180 + 46) / 2)) -- (-DockAppContext.width + dockItem.width) / 2
            , borderRadius (px 8)
            , cursor pointer
            , fontSize (px 12)
            , withClass Visible
                [ display block ]
            , children
                [ ul
                    [ padding (px 8)
                    , listStyle none
                    , children
                        [ li [ paddingLeft (px 8) ] ]
                    ]
                ]
            ]
        , class ClickableWindow
            [ cursor pointer
            , hover [ backgroundColor (rgba 0 0 0 0.5) ]
            ]
        ]
