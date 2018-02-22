module Apps.VirusPanel.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz)
import Css.Icons as Icon
import UI.Colors as Colors
import Apps.VirusPanel.Resources exposing (Classes(..), prefix)


ico : Style
ico =
    before
        [ Icon.fontFamily
        , textAlign center
        ]


css : Stylesheet
css =
    (stylesheet << namespace prefix)
        [ class Super
            [ displayFlex
            , flexDirection column
            , minWidth (pct 96)
            , minHeight (pct 94)
            , withClass TList tabList
            , withClass TCollect tabCollect
            , withClass TBotnet tabBotnet
            ]
        ]


tabList : List Style
tabList =
    [ overflow auto
    , children
        [ class ServerList
            [ children
                [ server
                ]
            ]
        ]
    ]


tabCollect : List Style
tabCollect =
    [ children
        [ class CollectTopBar
            [ height (pct 10)
            , padding4 (px 8) (px 0) (px 0) (px 8)
            ]
        , class CollectingVirusList
            [ borderTop3 (px 1) solid Colors.black
            , borderBottom3 (px 1) solid Colors.black
            , height (pct 92)
            , overflow auto
            , children
                [ colletingVirus ]
            ]
        , class CollectButtons
            [ displayFlex
            , flexDirection columnReverse
            , height (pct 8)
            , padding (px 8)
            , children
                [ class CollectButton
                    [ width (pct 10)
                    ]
                ]
            ]
        ]
    ]


tabBotnet : List Style
tabBotnet =
    [ textAlign center
    , justifyContent center
    ]


colletingVirus : Snippet
colletingVirus =
    class CollectingVirus
        [ borderBottom3 (px 1) solid Colors.black
        , padding (px 8)
        ]


server : Snippet
server =
    class Server
        [ borderBottom3 (px 1) solid Colors.black
        , padding (px 8)
        , children
            [ class ServerTop
                [ displayFlex
                , justifyContent spaceBetween
                ]
            ]
        ]
